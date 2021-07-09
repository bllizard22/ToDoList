//
//  Priority.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 08.06.2021.
//

import Foundation

public enum Priority: Int {
    case low = 0, moderate, high
}

extension Priority {
    public init?(value: String) {
        switch value.lowercased() {
        case "low":
            self = .low
        case "basic":
            self = .moderate
        case "important":
            self = .high
        default:
            self = .moderate
        }
    }
}
