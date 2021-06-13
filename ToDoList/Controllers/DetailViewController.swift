//
//  DetailViewController.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 13.06.2021.
//

import UIKit

class DetailViewController: UIViewController {

    var fileCache: FileCache!
    
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var importanceSegmets: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVC()
    }
    
    func setupVC() {
        textField.layer.cornerRadius = 16
        settingsView.layer.cornerRadius = 16
        deleteButton.layer.cornerRadius = 16
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        let rootVC = presentingViewController as! ViewController
        print(rootVC)
        rootVC.fileCache = fileCache
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveTask(_ sender: UIBarButtonItem) {
        
        let text = textField.text
        
        var importance: Priority
        switch importanceSegmets.numberOfSegments {
        case 0:
            importance = .low
        case 2:
            importance = .high
        default:
            importance = .moderate
        }
        
        let deadline = 1.0
        
        let item: TodoItem = TodoItem(text: text ?? "",
                                      importance: importance,
                                      deadline: deadline)
        fileCache.addNewTask(task: item)
    }
    @IBAction func deleteTask(_ sender: UIButton) {
        if let id = fileCache.todoItems.first?.value.id {
            fileCache.removeTask(withId: id)
        }
    }
}
