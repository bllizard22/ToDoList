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
        if doneFlag {
            return fileCache.todoItems.map { $0.value.id }.sorted()
        } else {
            let array = fileCache.todoItems.map { $0.value.id }.sorted()
            return array.filter { !fileCache.doneTasksList.contains($0) }
        }
    }

    var doneFlag = false
    
    @IBOutlet private weak var doneLabel: UILabel!
    @IBOutlet private weak var showDoneButton: UIButton!
    @IBOutlet weak var taskTableView: UITableView!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        taskTableView.delegate = self
        taskTableView.dataSource = self
        taskTableView.register(UINib(nibName: "TaskTableViewCell", bundle: nil),
                               forCellReuseIdentifier: "taskCell")
        
        buildModel = BuildVersionModel()
        fileCache = FileCache(forFile: "defaultList.txt")
        
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
    
    // MARK: - IBActions
    
    @IBAction func doneButtonDidPressed(_ sender: UIButton) {
        doneFlag = !doneFlag
        taskTableView.reloadData()
        if doneFlag {
            showDoneButton.setTitle("Hide", for: .normal)
        } else {
            showDoneButton.setTitle("Show", for: .normal)
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
    
    private func showErrorAlert(forError error: Error) {
        let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
    }
    
}

// MARK: - Extension for TableView methods

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rawCell = taskTableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        
        guard let cell = rawCell as? TaskTableViewCell else { return rawCell }
            let id = tasksList[indexPath.row]
            let text = fileCache.todoItems[id]?.text ?? ""
        if doneFlag, fileCache.doneTasksList.contains(id) {
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
                    attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
                cell.taskLabel.textColor = .systemGray3
                cell.taskLabel.attributedText = attributeString
                cell.doneButton.setImage(UIImage(named: "Bounds"), for: .normal)
            } else {
                let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
                cell.taskLabel.attributedText = attributeString
                cell.taskLabel.textColor = UIColor(named: "Text")
                if fileCache.todoItems[id]?.importance == Priority.high {
                    cell.doneButton.setImage(UIImage(named: "Group 1"), for: .normal)
                } else {
                    cell.doneButton.setImage(UIImage(named: "Ellipse"), for: .normal)
                }
            }
         
        cell.taskLabel.sizeToFit()
        cell.taskLabel.numberOfLines = 3
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let id = tasksList[indexPath.row]
        let floatSize = CGFloat(fileCache.todoItems[id]?.text.components(separatedBy: "\n").count ?? 1)
        let size = (floatSize - 1)  * 20.0 + 56.0
        return min(98, size)
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
                                        handler: { [ weak self ] _, _, _ in
                                            let id = self?.tasksList[indexPath.row] ?? ""
                                            self?.fileCache.toggleTaskDone(forID: id)
                                            self?.taskTableView.reloadData()
                                        }
        )
        action.image = UIImage(named: "Cell")
        action.backgroundColor = UIColor(named: "Green")
        doneLabel.text = "Done - \(fileCache.doneTasksList.count)"
        
        return action
    }
    
    private func deleteAction(_ indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal,
                                        title: "",
                                        handler: { [ weak self ] _, _, _ in
                                            let id = self?.tasksList[indexPath.row] ?? ""
                                            self?.fileCache.removeTask(withId: id)
                                            self?.taskTableView.reloadData()
                                        }
        )
        action.image = UIImage(named: "Bin")
        action.backgroundColor = UIColor(named: "DeleteColor")
        doneLabel.text = "Done - \(fileCache.doneTasksList.count)"
        
        return action
    }
    
}
