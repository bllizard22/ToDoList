//
//  NetworkingService.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 04.07.2021.
//

import Foundation

protocol NetworkingService {
    func getTasks(completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    
    func addTask(_ task: TodoItem, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    
    func updateTask(_ task: TodoItem, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    
    func deleteTask(withId id: String, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
    
    func syncTasks(deleted: [String], modified: [TodoItem], completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void)
}
