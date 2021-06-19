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

    @IBOutlet private weak var iconImage: UIImageView!
    @IBOutlet private weak var buildLabel: UILabel!

    @IBOutlet private weak var readButton: UIButton!
    @IBOutlet private weak var writeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildModel = BuildVersionModel()
        fileCache = FileCache(forFile: "defaultList.txt")
        do {
            try fileCache.loadFromFile()
        } catch let error {
            showErrorAlert(forError: error)
        }
    }

    @IBAction private func readButtonDidTouched(_ sender: UIButton) {
        do {
            try fileCache.loadFromFile()
        } catch let error {
            showErrorAlert(forError: error)
        }
    }
    
    @IBAction private func writeButtonDidTouched(_ sender: Any) {
        do {
            try fileCache.saveToFile()
        } catch let error {
            showErrorAlert(forError: error)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openTaskDetail" {
            guard let destination = segue.destination as? UINavigationController else { return }
            guard let topVC = destination.topViewController as? DetailViewController else { return }
            topVC.fileCache = fileCache
        }
    }
    
    private func showErrorAlert(forError error: Error) {
        let alertVC = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
    }
    
    // MARK: - create tasks for debug purposes
    func createItems() {

        let item = TodoItem(text: "sell smth",
                            importance: .high,
                            deadline: Date(timeIntervalSinceNow: 3600*24*7))
        fileCache.addNewTask(task: item)
        
        let item2 = TodoItem(text: "buy smth", importance: .moderate)
        fileCache.addNewTask(task: item2)
        
        let item3 = TodoItem(text: "buy 3 smth", importance: .moderate)
        fileCache.addNewTask(task: item3)
        fileCache.removeTask(withId: item3.id)
        
    }
    
}
