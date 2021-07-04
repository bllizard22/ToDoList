//
//  TodoItemJSON.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 10.06.2021.
//

import Foundation

extension TodoItem {
    
    static func parseJSON(data: Any) -> TodoItem? {
        guard let dict = data as? [String: Any] else { return nil }
        guard let id = dict["id"] as? String else { return nil }
        guard let text = dict["text"] as? String else { return nil }
        
        let importance = (dict["importance"] as? Int).flatMap(Priority.init(rawValue:)) ?? .moderate
        
        let deadline = dict["deadline"] as? Date
        
        let isDone = dict["isDone"] as? Bool ?? false
        
        return self.init(id: id,
                         text: text,
                         importance: importance,
                         deadline: deadline,
                         isDone: isDone)
    }
    
    var json: [String: Any] {
        return [
            "id": id,
            "text": text,
            "importance": importance.rawValue,
            "deadline": deadline?.timeIntervalSince1970 as Any,
            "isDone": isDone
        ]
    }
    
}
