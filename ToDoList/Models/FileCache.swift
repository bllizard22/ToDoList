//
//  FileCache.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 08.06.2021.
//

import Foundation
import SQLite

enum FileCacheError: Error {
    case parsingError
    case fileAccessError
}

final class FileCache {
    
    private var fileName: String
    private(set) var todoItems: [String: TodoItem]
    private(set) weak var delegate: ViewController?
    
    var doneTasksList: [String] {
        self.todoItems.filter { $0.value.isDone }.map { $0.value.id }.sorted()
    }

    let networkingService = DefaultNetworkingService()
    
    private let fileManager = FileManager()
    private var cacheDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    private var database: Connection?
    private var tasksTable = Table("tasks")
    let id = Expression<String>("id")
    let text = Expression<String>("text")
    let importance = Expression<String>("importance")
    let deadline = Expression<TimeInterval?>("deadline")
    let isDone = Expression<Bool>("done")
    let createdAt = Expression<TimeInterval>("created_at")
    let updatedAt = Expression<TimeInterval>("updated_at")
    let isDirty = Expression<Bool>("dirty")
    
    init(forFile: String, delegate: ViewController) {
        self.delegate = delegate
        self.todoItems = [String: TodoItem]()
        self.fileName = forFile

        createDataBase()
    }

    @discardableResult func toggleTaskDone(forID id: String) -> TodoItem? {
        todoItems[id]?.toggleDoneStatus()
        return todoItems[id]
    }
    
    func addNewTask(_ task: TodoItem) {
        if todoItems.keys.contains(task.id) {
            updateTask(task, needToToggleDone: false)
        } else {
            networkingService.addTask(task) { _, response, error in
                if error != nil, response == nil, !task.isDirty {
                    self.todoItems[task.id]?.toggleDirtyState()
                    return
                }
            }
            addTaskToDatabase(task)
        }
        todoItems[task.id] = task
    }

    func updateTask(_ task: TodoItem, needToToggleDone: Bool) {
        todoItems[task.id] = task
        var newTask = task
        if needToToggleDone {
            toggleTaskDone(forID: task.id)
            newTask.toggleDoneStatus()
            newTask.updateDate()
        }
        print("\(task.isDone) -> \(newTask.isDone)")
        networkingService.updateTask(newTask) { _, response, error in
            if error != nil, response == nil, !task.isDirty {
                self.todoItems[newTask.id]?.toggleDirtyState()
                print("Error on update!")
                return
            }
        }
        updateTaskInDatabase(newTask)
    }
    
    func removeTask(withId idVal: String) {
        todoItems.removeValue(forKey: idVal)
        networkingService.deleteTask(withId: idVal, completion: { _, response, error in
            if error != nil, response == nil {
                self.todoItems[idVal]?.toggleDirtyState()
                return
            }
        })

        deleteTaskFromDatabase(atId: idVal)
    }
    
    func saveToFile() throws {
        do {
        try DispatchQueue.global(qos: .background).sync(execute: { () -> Void in
            guard let path = cacheDir?.appendingPathComponent(fileName) else {
                throw FileCacheError.fileAccessError
            }
            var dictToSave = [String: Any]()
            for item in self.todoItems.values {
                dictToSave[item.id] = item.json
            }
            
            do {
                print("JSON is valid", JSONSerialization.isValidJSONObject(dictToSave))
                let data = try JSONSerialization.data(withJSONObject: dictToSave, options: [])
                let contentsOfFile = data
                
                do {
                    try contentsOfFile.write(to: path, options: [])
                    print("File \(fileName) created")
                } catch {
                    throw FileCacheError.fileAccessError
                }
            } catch {
                throw FileCacheError.parsingError
            }
        })
        } catch let error as FileCacheError {
            throw error
        }
    }
    
    func loadFromFile() throws {
        do {
            try DispatchQueue.global(qos: .background).sync(execute: { () -> Void in
                guard try checkDirectory() != nil else {
                    throw FileCacheError.fileAccessError
                }
                
                guard let filePath = cacheDir?.appendingPathComponent(fileName) else {
                    throw FileCacheError.fileAccessError
                }
                
                do {
                    let fileContent = try Data(contentsOf: filePath, options: [])
                    print("Content of the file is: \(fileContent)")
                    let jsonRaw = try JSONSerialization.jsonObject(with: fileContent, options: .allowFragments) as? [String: Any]
                    guard let json = jsonRaw else { return }
                    for value in json.values {
                        if let item = TodoItem.parseJSON(data: value) {
                            self.todoItems[item.id] = item
                        }
                    }
                } catch {
                    throw FileCacheError.fileAccessError
                }
                syncWithServer()
            })
        }
    }

    private func syncWithServer() {
        networkingService.getTasks { data, response, error in
            if error != nil, response == nil {
                return
            }
            
            guard let data = data else { return }

            let itemsRaw = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any]
            guard let items = itemsRaw else { return }
            let remoteItems = items.compactMap { TodoItem.parseJSON(data: $0) }
            print("On server: \(remoteItems)")
            let remoteIds = remoteItems.map { $0.id }

            for item in remoteItems {
                if !self.todoItems.keys.contains(item.id) {
                    self.addNewTask(item)
                } else {
                    let id = item.id
                    if let task = self.todoItems[id], item.updatedAt > task.updatedAt {
                        self.todoItems[id] = item
                    }
                }
            }

            for id in self.todoItems.keys {
                if !remoteIds.contains(id) {
                    self.removeTask(withId: id)
                }
            }

            self.getTasksFromDatabase()

            DispatchQueue.main.async {
                self.delegate?.reloadTasksTableView()
                self.delegate?.stopActivityIndicator()
            }
        }
    }
    
    private func checkDirectory() throws -> String? {
        do {
            guard let path = cacheDir?.path else { return nil }
            let dirPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
            if !FileManager.default.fileExists(atPath: dirPath!.path) {
                try FileManager.default.createDirectory(atPath: dirPath!.path, withIntermediateDirectories: true, attributes: nil)
            }
            
            let files = try fileManager.contentsOfDirectory(atPath: path)
            if !files.isEmpty {
                print("Files in dir: \(files)")
                if files.contains(fileName) {
                    print("'\(fileName)' found")
                    return fileName
                } else {
                    print("File not found")
                    return nil
                }
            }
        } catch {
            throw FileCacheError.fileAccessError
        }
        return nil
    }

    // MARK: - Database

    private func createDataBase() {
        guard let dbDir = cacheDir?.appendingPathComponent("tasks.sqlite").path else { return }
        var db: OpaquePointer?
        guard sqlite3_open(dbDir, &db) == SQLITE_OK else {
            print("error opening database")
            sqlite3_close(db)
            db = nil
            return
        }

        do {
            database = try Connection(dbDir)

            try database?.run(tasksTable.create { table in
                table.column(id, primaryKey: true)
                table.column(text)
                table.column(importance)
                table.column(deadline)
                table.column(isDone)
                table.column(createdAt)
                table.column(updatedAt)
                table.column(isDirty)
            })

            print("\n\nDB created!\n\n")

            for task in try database!.prepare(tasksTable) {
                print("id: \(task[id]), text: \(task[text]), importance: \(task[importance])")
            }

        } catch {
            print("Error with DB init")
        }
    }

    private func getTasksFromDatabase() {

    }

    private func addTaskToDatabase(_ task: TodoItem) {
        let idVal = task.json["id"] as? String ?? ""
        let textVal = task.json["text"] as? String ?? ""
        let importanceVal = task.json["importance"] as? String ?? ""
        let deadlineVal = task.json["deadline"] as? TimeInterval ?? Date().timeIntervalSince1970
        let isDoneVal = task.json["done"] as? Bool ?? false
        let createdAtVal = task.json["created_at"] as? TimeInterval ?? Date().timeIntervalSince1970
        let updatedAtVal = task.json["updated_at"] as? TimeInterval ?? Date().timeIntervalSince1970
        let insert = tasksTable.insert(id <- idVal,
                                       text <- textVal,
                                       importance <- importanceVal,
                                       deadline <- deadlineVal,
                                       isDone <- isDoneVal,
                                       createdAt <- createdAtVal,
                                       updatedAt <- updatedAtVal,
                                       isDirty <- false)
        do {
            let rowid = try database?.run(insert)
            print("\n\(idVal) Inserted!\n")
        } catch {
            print("DB Insert error")
        }
    }

    private func updateTaskInDatabase(_ task: TodoItem) {
        let idVal = task.json["id"] as? String ?? ""
        let textVal = task.json["text"] as? String ?? ""
        let importanceVal = task.json["importance"] as? String ?? ""
        let deadlineVal = task.json["deadline"] as? TimeInterval ?? Date().timeIntervalSince1970
        let isDoneVal = task.json["done"] as? Bool ?? false
        let createdAtVal = task.json["created_at"] as? TimeInterval ?? Date().timeIntervalSince1970
        let updatedAtVal = task.json["updated_at"] as? TimeInterval ?? Date().timeIntervalSince1970
        let update = tasksTable.update(id <- idVal,
                                       text <- textVal,
                                       importance <- importanceVal,
                                       deadline <- deadlineVal,
                                       isDone <- isDoneVal,
                                       createdAt <- createdAtVal,
                                       updatedAt <- updatedAtVal,
                                       isDirty <- false)
        do {
            let rowid = try database?.run(update)
            print("\n\(idVal) Inserted!\n")
        } catch {
            print("DB Insert error")
        }
    }

    private func deleteTaskFromDatabase(atId idVal: String) {
        let itemToDelete = tasksTable.filter(id == idVal)
        do {
            try database?.run(itemToDelete.delete())
            print("\n\(idVal) Deleted\n")
        } catch {
            print("Error in DELETE")
        }
    }
}
