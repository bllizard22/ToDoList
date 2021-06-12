//
//  TodoItemJSON.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 10.06.2021.
//

import Foundation

extension TodoItem {
    
    static func parseJSON(data: Any) -> TodoItem? {
        let dict = data as? [String: Any]
        let id = dict?["id"] as? String ?? "0"
        let text = dict?["text"] as? String ?? "0"
        
        var importance: Priority
        switch dict?["importance"] as? Int ?? 1 {
        case 0:
            importance = Priority.low
        case 2:
            importance = Priority.high
        default:
            importance = Priority.moderate
        }
        
        let deadlineRaw = dict?["deadline"] as? Double ?? 0
        var deadline: Double?
        if deadlineRaw == 0 {
            deadline = nil
        } else {
            deadline = deadlineRaw
        }
        
        return self.init(id: id,
                         text: text,
                         importance: importance,
                         deadline: deadline)
    }
    
    var json: [String: Any] {
        return ["id": id,
                "text": text,
                "importance": importance.rawValue,
                "deadline": deadline ?? 0]
    }
    
}
