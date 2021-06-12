//
//  FileCache.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 08.06.2021.
//

import Foundation

class FileCache {
    
    public private(set) var todoItems: [String: TodoItem]
    private var fileName: String
    
    private let fileManager = FileManager()
    private var cacheDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    
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
    
    func saveToFile() {
        guard let path = cacheDir?.appendingPathComponent(fileName) else { return }
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
            } catch let error as NSError {
                print("could't create file text.txt because of error: \(error)")
            }
        } catch let error as NSError {
            print("Error in JSONSerialization: \(error)")
        }
    }
    
    func loadFromFile() {

        guard let filePath = cacheDir?.appendingPathComponent(fileName) else { return }
        
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
        } catch let error as NSError {
            print("There is an reading error: \(error)")
        }
    }
    
    private func checkDirectory() -> String? {
        do {
            guard let path = cacheDir?.path else { return nil }
            let dirPath = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last
            if !FileManager.default.fileExists(atPath: dirPath!.path) {
                try FileManager.default.createDirectory(atPath: dirPath!.path, withIntermediateDirectories: true, attributes: nil)
            }
            
            let filesInDirectory = try fileManager.contentsOfDirectory(atPath: path)
            let files = filesInDirectory
            if files.count > 0 {
                print("Files in dir: \(files)")
                if files.contains(fileName) {
                    print("\(fileName) found")
                    return fileName
                } else {
                    print("File not found")
                    return nil
                }
            }
        } catch let error as NSError {
            print(error)
        }
        return nil
    }
}
