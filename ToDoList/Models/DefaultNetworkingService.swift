//
//  DefaultNetworkingService.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 04.07.2021.
//

import Foundation

class DefaultNetworkingService: NetworkingService {

    let yandexBackendURL = "https://d5dps3h13rv6902lp5c8.apigw.yandexcloud.net/tasks/"
    let bearerToken = "Bearer ODgwNDE2NDI4ODExNzM4MTY0MQ"

    func getTasks(completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let session: URLSession = {
            let session = URLSession(configuration: .default)
            session.configuration.timeoutIntervalForRequest = 30.0
            return session
        }()
        
        var request = URLRequest(url: URL(string: yandexBackendURL)!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = ["Authorization": bearerToken]
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            
            if let response = response, let data = data {
                completion(data, response as? HTTPURLResponse, nil)
            }
        }
        dataTask.resume()
    }
    
    func addTask(_ task: TodoItem, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let session: URLSession = {
            let session = URLSession(configuration: .default)
            session.configuration.timeoutIntervalForRequest = 30.0
            return session
        }()
        let url = URL(string: yandexBackendURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json",
                                       "Authorization": bearerToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: task.json, options: [])
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            
            if let response = response, let data = data {
                completion(data, response as? HTTPURLResponse, nil)
            }
            
            return
        }
        dataTask.resume()
    }
    
    func updateTask(_ task: TodoItem, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let session: URLSession = {
            let session = URLSession(configuration: .default)
            session.configuration.timeoutIntervalForRequest = 30.0
            return session
        }()
        let url = URL(string: yandexBackendURL + task.id)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = ["Content-Type": "application/json",
                                       "Authorization": bearerToken]
        request.httpBody = try? JSONSerialization.data(withJSONObject: task.json, options: [])
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            
            if let response = response, let data = data {
                completion(data, response as? HTTPURLResponse, nil)
            }
            
            return
        }
        dataTask.resume()
    }
    
    func deleteTask(withId id: String, completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let session: URLSession = {
            let session = URLSession(configuration: .default)
            session.configuration.timeoutIntervalForRequest = 30.0
            return session
        }()
        let url = URL(string: yandexBackendURL + id)!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.allHTTPHeaderFields = ["Authorization": bearerToken]
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            
            if let response = response, let data = data {
                completion(data, response as? HTTPURLResponse, nil)
            }
            
            return
        }
        dataTask.resume()
    }
    
    func syncTasks(deleted: [String], modified: [TodoItem], completion: @escaping (Data?, HTTPURLResponse?, Error?) -> Void) {
        let session: URLSession = {
            let session = URLSession(configuration: .default)
            session.configuration.timeoutIntervalForRequest = 30.0
            return session
        }()
        let url = URL(string: yandexBackendURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.allHTTPHeaderFields = ["Content-Type": "application/json",
                                       "Authorization": bearerToken]
        
        let json: [String: Any] = ["deleted": deleted, "other": modified]
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [])
        
        let dataTask = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            
            if let response = response, let data = data {
                completion(data, response as? HTTPURLResponse, nil)
            }
            
            return
        }
        dataTask.resume()
    }
}
