//
//  DetailViewController.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 13.06.2021.
//

import UIKit

class DetailViewController: UIViewController {

    var fileCache: FileCache!
    var deadlinePicker: UIDatePicker!
    
    @IBOutlet weak var textField: UITextView!
    @IBOutlet weak var settingsView: UIView!
    @IBOutlet weak var settingsStack: UIStackView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var importanceSegmets: UISegmentedControl!
    @IBOutlet weak var deadlineStack: UIStackView!
    @IBOutlet weak var deadlineSwitch: UISwitch!
    
    @IBOutlet weak var settingsViewHeightConstraint: NSLayoutConstraint!
//    let small = settingsView.heightAnchor.constraint(equalToConstant: 112)
//    let big = settingsView.heightAnchor.constraint(equalToConstant: 300)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVC()
    }
    
    func setupVC() {
        textField.layer.cornerRadius = 16
        deleteButton.layer.cornerRadius = 16
        settingsView.layer.cornerRadius = 16
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }

    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        guard let rootVC = presentingViewController as? ViewController else { return }
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
        
        let deadline = deadlineSwitch.isOn ? deadlinePicker.date.timeIntervalSince1970 : nil
        
        let item: TodoItem = TodoItem(text: text ?? "",
                                      importance: importance,
                                      deadline: deadline)
        fileCache.addNewTask(task: item)
    }
    
    @IBAction func deadlineSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            deadlinePicker = UIDatePicker()
            deadlinePicker.tag = 5
            if #available (iOS 14, *) {
                deadlinePicker.preferredDatePickerStyle = .inline
            }
            deadlinePicker.datePickerMode = .date
            deadlinePicker.minimumDate = Date(timeIntervalSinceNow: 0)
            
            settingsViewHeightConstraint.constant += deadlinePicker.frame.height + settingsStack.spacing
            settingsStack.addArrangedSubview(deadlinePicker)
            
//            settingsStack.spacing = 11
            
            settingsView.setNeedsLayout()
        } else {
            settingsViewHeightConstraint.constant -= deadlinePicker.frame.height + settingsStack.spacing
//            settingsStack.spacing = 11
            
            for view in settingsStack.subviews where view.tag == 5 {
                view.removeFromSuperview()
            }
            settingsView.setNeedsLayout()
        }
    }
    
    @IBAction func deleteTask(_ sender: UIButton) {
        if let id = fileCache.todoItems.first?.value.id {
            fileCache.removeTask(withId: id)
        }
    }
}
