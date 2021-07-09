//
//  TodoItemJSON.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 10.06.2021.
//

import Foundation
import PriorityEnum

extension TodoItem {
    
    static func parseJSON(data: Any) -> TodoItem? {
        guard let dict = data as? [String: Any] else { return nil }
        guard let id = dict["id"] as? String else { return nil }
        guard let text = dict["text"] as? String else { return nil }
        
        let importance = (dict["importance"] as? String).flatMap(Priority.init(value:)) ?? .moderate
        
        let deadlineTimestamp = dict["deadline"] as? TimeInterval
        var deadline: Date?
        if deadlineTimestamp != nil {
            deadline = Date(timeIntervalSince1970: deadlineTimestamp!)
        }
        
        let isDone = dict["done"] as? Bool ?? false
        
        let createdAt = dict["created_at"] as? Double ?? Date().timeIntervalSince1970
        let updatedAt = dict["updated_at"] as? Double ?? createdAt
        
        return self.init(id: id,
                         text: text,
                         importance: importance,
                         deadline: deadline,
                         isDone: isDone,
                         created: createdAt,
                         updated: updatedAt)
    }
    
    var json: [String: Any] {
        let priority: String
        switch importance.rawValue {
        case 0:
            priority = "low"
        case 1:
            priority = "basic"
        case 2:
            priority = "important"
        default:
            priority = "basic"
        }

        let deadlineTimestamp = deadline?.timeIntervalSince1970
        let deadlineVal : Any
        if deadlineTimestamp != nil {
            deadlineVal = deadlineTimestamp!
        } else {
            deadlineVal = NSNull()
        }

        return [
            "id": id,
            "text": text,
            "importance": priority,
            "deadline": deadlineVal,
            "done": isDone,
            "created_at": Int(createdAt),
            "updated_at": Int(updatedAt)
        ]
    }
    
}
