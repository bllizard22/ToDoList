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
    
    private(set) var todoItems: [String: TodoItem]
    private var fileName: String
    
    private let fileManager = FileManager()
    private var cacheDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    init(forFile: String) {
        self.todoItems = [String: TodoItem]()
        self.fileName = forFile
    }
    
    func addNewTask(task: TodoItem) {
        todoItems[task.id] = task
    }
    
    func removeTask(withId id: String) {
        todoItems.removeValue(forKey: id)
    }
    
    func saveToFile() throws {
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
    }
    
    func loadFromFile() throws {
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
            print(jsonRaw ?? "empty json")
            guard let json = jsonRaw else { return }
            for value in json.values {
                if let item = TodoItem.parseJSON(data: value) {
                    self.todoItems[item.id] = item
                }
            }
            print(todoItems)
        } catch {
            throw FileCacheError.fileAccessError
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
