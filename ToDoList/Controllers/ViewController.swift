//
//  ViewController.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 06.06.2021.
//

import UIKit

class ViewController: UIViewController {

    var buildModel: BuildVersionModel!
    var fileCache: FileCache!
    
    @IBOutlet private weak var doneLabel: UILabel!
    @IBOutlet weak var showDoneButton: UIButton!
    @IBOutlet weak var taskTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTableView.delegate = self
        taskTableView.dataSource = self
        
        buildModel = BuildVersionModel()
        fileCache = FileCache(forFile: "defaultList.txt")
        createItems()
        do {
            try fileCache.loadFromFile()
        } catch let error {
            showErrorAlert(forError: error)
        }
    }

    func readFile() {
        do {
            try fileCache.loadFromFile()
        } catch let error {
            showErrorAlert(forError: error)
        }
    }
    
    func writeFile() {
        do {
            try fileCache.saveToFile()
        } catch let error {
            showErrorAlert(forError: error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskDetailSegue" {
            guard let destination = segue.destination as? UINavigationController else { return }
            guard let topVC = destination.topViewController as? DetailViewController else { return }
            topVC.currentItem = fileCache.todoItems.values.first
        }
    }
    
    private func showErrorAlert(forError error: Error) {
        let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
    }
    
    // MARK: - Create tasks, for debug purposes
    func createItems() {

        let item = TodoItem(text: "sell smth",
                            importance: .high,
                            deadline: Date(timeIntervalSinceNow: 3600*24*7))
        fileCache.addNewTask(task: item)
        
        let item2 = TodoItem(text: "buy smth", importance: .moderate)
        fileCache.addNewTask(task: item2)
        
        let item3 = TodoItem(text: "buy 3 smth", importance: .moderate)
        fileCache.addNewTask(task: item3)
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileCache.todoItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        taskTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil),
                                          forCellReuseIdentifier: "taskCell")
        let cell = taskTableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
                
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "taskDetailSegue", sender: nil)
    }
    
}
