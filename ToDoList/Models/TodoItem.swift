//
//  TodoItem.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 08.06.2021.
//

import Foundation

struct TodoItem {
    let id: String
    let text: String
    let importance: Priority
    let deadline: Date?
    
    var isDone: Bool
    
    mutating func toggleDoneStatus() {
        isDone = !isDone
    }
    
    init(id: String = UUID().uuidString,
         text: String,
         importance: Priority,
         deadline: Date? = nil,
         isDone: Bool = false) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
    }
    
    
}
