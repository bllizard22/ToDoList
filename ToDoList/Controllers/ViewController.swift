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
    var tasksList: [String] {
        fileCache.todoItems.map { $0.value.id }.sorted()
    }
    var doneTasksList = [String]()
    
    @IBOutlet private weak var doneLabel: UILabel!
    @IBOutlet private weak var showDoneButton: UIButton!
    @IBOutlet weak var taskTableView: UITableView!
    
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTableView.delegate = self
        taskTableView.dataSource = self
        
        buildModel = BuildVersionModel()
        fileCache = FileCache(forFile: "defaultList.txt")
//        createItems()
        do {
            try fileCache.loadFromFile()
        } catch let error {
            showErrorAlert(forError: error)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            try fileCache.saveToFile()
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
    
    @IBAction func addNewTaskDidPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "taskDetailSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskDetailSegue" {
            guard let destination = segue.destination as? UINavigationController else { return }
            guard let topVC = destination.topViewController as? DetailViewController else { return }
            if let id = sender as? String {
                topVC.currentItem = fileCache.todoItems[id]
            } else {
                topVC.currentItem = nil
            }
        }
    }
    
    override func updateViewConstraints() {
        tableViewHeightConstraint.constant = taskTableView.contentSize.height
        super.updateViewConstraints()
        doneLabel.text = "Done - \(doneTasksList.count)"
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
        
        do {
            try fileCache.saveToFile()
        } catch {
            showErrorAlert(forError: FileCacheError.fileAccessError)
        }
    }
    
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        taskTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "taskCell")
        
        let cell = taskTableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        
        if let cell = cell as? TaskTableViewCell {
            let id = tasksList[indexPath.row]
            let text = fileCache.todoItems[id]
            cell.taskLabel.text = text?.text
        }
         
        updateViewConstraints()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "taskDetailSegue", sender: tasksList[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [doneAction(indexPath)])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [deleteAction(indexPath)])
    }
    
    private func doneAction(_ indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal,
                                        title: "",
                                        handler: { [ weak self ] (action, view, completion) in
                                            self?.doneTasksList.append(self?.tasksList[indexPath.row] ?? "")
                                        }
        )
        action.image = UIImage(named: "Cell")
        action.backgroundColor = UIColor(named: "Green")
        return action
    }
    
    private func deleteAction(_ indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal,
                                        title: "",
                                        handler: { [ weak self ] (action, view, completion) in
                                            let id = self?.tasksList[indexPath.row] ?? ""
                                            self?.fileCache.removeTask(withId: id)
                                            self?.taskTableView.reloadData()
                                        }
        )
        action.image = UIImage(named: "Bin")
        action.backgroundColor = UIColor(named: "DeleteColor")
        return action
    }
    
}
