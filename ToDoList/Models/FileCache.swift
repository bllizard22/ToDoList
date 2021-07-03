//
//  FileCache.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 08.06.2021.
//

import Foundation

enum FileCacheError: Error {
    case parsingError
    case fileAccessError
}

final class FileCache {
    
    private var fileName: String
    private(set) var todoItems: [String: TodoItem]
    
    var doneTasksList: [String] {
        self.todoItems.filter { $0.value.isDone }.map { $0.value.id }.sorted()
    }
    
    let networkingService = DefaultNetworkingService()
    
    private let fileManager = FileManager()
    private var cacheDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    init(forFile: String) {
        self.todoItems = [String: TodoItem]()
        self.fileName = forFile
    }
    
    func toggleTaskDone(forID id: String) {
        todoItems[id]?.toggleDoneStatus()
        networkingService.getTasks { data, response, error in
            if error != nil, response == nil {
                return
            }
            
            if let data = data {
                let itemsRaw = try? JSONSerialization.jsonObject(with: data, options: []) as? [Any]
                guard let items = itemsRaw else { return }
                for item in items {
                    let json = TodoItem.parseJSON(data: item)
                    print("Data:\n", json)
                }
            }
        }
    }
    
    func addNewTask(task: TodoItem) {
        if todoItems.keys.contains(task.id) {
            networkingService.updateTask(task) { data, response, error in
                if error != nil, response == nil {
                    return
                }
                
                if let data = data {
                    let itemRaw = try? JSONSerialization.jsonObject(with: data, options: []) as? Any
                    guard let item = itemRaw else { return }
                    let json = TodoItem.parseJSON(data: item)
                    print("Data:\n", json)
                }
            }
        } else {
            networkingService.addTask(task) { data, response, error in
                if error != nil, response == nil {
                    return
                }
                
                if let data = data {
                    let itemRaw = try? JSONSerialization.jsonObject(with: data, options: []) as? Any
                    guard let item = itemRaw else { return }
                    let json = TodoItem.parseJSON(data: item)
                    print("Data:\n", json)
                }
            }
        }
        
        todoItems[task.id] = task
    }
    
    func removeTask(withId id: String) {
        todoItems.removeValue(forKey: id)
        networkingService.deleteTask(withId: id, completion: { data, response, error in
            if error != nil, response == nil {
                return
            }
            
            if let data = data {
                let itemRaw = try? JSONSerialization.jsonObject(with: data, options: []) as? Any
                guard let item = itemRaw else { return }
                let json = TodoItem.parseJSON(data: item)
                print("Data:\n", json)
            }
        })
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
            })
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
}
