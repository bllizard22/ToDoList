//
//  TodoItem.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 08.06.2021.
//

import Foundation
import PriorityEnum

struct TodoItem {
    let id: String
    let text: String
    let importance: Priority
    let deadline: Date?
    
    var isDone: Bool
    let createdAt: TimeInterval
    var updatedAt: TimeInterval
    var isDirty: Bool
    
    mutating func toggleDoneStatus() {
        isDone = !isDone
    }
    
    mutating func updateDate() {
        updatedAt = Date().timeIntervalSince1970
    }
    
    mutating func toggleDirtyState() {
        isDirty = !isDirty
    }
    
    init(id: String = UUID().uuidString,
         text: String,
         importance: Priority,
         deadline: Date? = nil,
         isDone: Bool = false,
         created: TimeInterval = Date().timeIntervalSince1970,
         updated: TimeInterval = Date().timeIntervalSince1970,
         isDirty: Bool = false) {
        self.id = id
        self.text = text
        self.importance = importance
        self.deadline = deadline
        self.isDone = isDone
    
        self.createdAt = created
        self.updatedAt = updated
        self.isDirty = false
    }
    
    
}
