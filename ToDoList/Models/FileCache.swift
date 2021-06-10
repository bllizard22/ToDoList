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
    private let tempDir = NSTemporaryDirectory()
    
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
        let path = (tempDir as NSString).appendingPathComponent(fileName)
        let contentsOfFile = "Some Text Here" // TodoItem.parse() here
        
        do {
            try contentsOfFile.write(toFile: path, atomically: true, encoding: String.Encoding.utf8)
            print("File \(fileName) created at temp directory")
        } catch let error as NSError {
            print("could't create file text.txt because of error: \(error)")
        }
    }
    
    func loadFromFile() {
        let dirWithFiles = checkDirectory() ?? "Empty"
        
        let path = (tempDir as NSString).appendingPathComponent(dirWithFiles)
        
        do {
            let fileContent = try NSString(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue)
            print("Content of the file is: \(fileContent)")
        } catch let error as NSError {
            print("There is an reading error: \(error)")
        }
    }
    
    private func checkDirectory() -> String? {
        do {
            let filesInDirectory = try fileManager.contentsOfDirectory(atPath: tempDir)
            
            let files = filesInDirectory
            if files.count > 0 {
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
