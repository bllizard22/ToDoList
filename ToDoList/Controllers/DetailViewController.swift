//
//  DetailViewController.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 13.06.2021.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {

    var fileCache: FileCache?
    var currentItem: TodoItem?
    var rootVC: ViewController?
    
    var deadlinePicker: UIDatePicker!
    
    @IBOutlet private weak var saveButton: UIBarButtonItem!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var settingsView: UIView!
    @IBOutlet private weak var settingsStack: UIStackView!
    @IBOutlet private weak var deleteButton: UIButton!
    @IBOutlet private weak var importanceSegmets: UISegmentedControl!
    @IBOutlet private weak var deadlineStack: UIStackView!
    @IBOutlet private weak var deadlineSwitch: UISwitch!
    
    @IBOutlet private weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet private weak var settingsViewHeightConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupVC()
    }
    
    private func setupVC() {
        textView.layer.cornerRadius = 16
        deleteButton.layer.cornerRadius = 16
        deleteButton.setTitleColor(.red, for: .normal)
        deleteButton.setTitleColor(.systemGray4, for: .disabled)
        settingsView.layer.cornerRadius = 16
        settingsView.translatesAutoresizingMaskIntoConstraints = false
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        rootVC = presentingViewController as? ViewController
        textView.delegate = self
    }

    @IBAction private func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction private func saveTask(_ sender: UIBarButtonItem) {
        let text = textView.text
        
        var importance: Priority
        print("Current segment \(importanceSegmets.selectedSegmentIndex)")
        switch importanceSegmets.selectedSegmentIndex {
        case 0:
            importance = .low
        case 2:
            importance = .high
        default:
            importance = .moderate
        }
        
        let deadline = deadlineSwitch.isOn ? deadlinePicker.date : nil
        
        let item: TodoItem = TodoItem(text: text ?? "",
                                      importance: importance,
                                      deadline: deadline)
        rootVC?.fileCache.addNewTask(task: item)
        
        dismiss(animated: true, completion: nil)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = textView.text != nil && textView.text != ""
    }
    
    @IBAction private func deadlineSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            deadlinePicker = UIDatePicker()
            deadlinePicker.tag = 5
            if #available (iOS 14, *) {
                deadlinePicker.preferredDatePickerStyle = .inline
            }
            deadlinePicker.datePickerMode = .date
            deadlinePicker.minimumDate = Date()
            
            settingsViewHeightConstraint.constant += deadlinePicker.frame.height + settingsStack.spacing
            settingsStack.addArrangedSubview(deadlinePicker)
                        
            settingsView.setNeedsLayout()
        } else {
            settingsViewHeightConstraint.constant -= deadlinePicker.frame.height + settingsStack.spacing
            
            deadlinePicker.removeFromSuperview()
            settingsView.setNeedsLayout()
        }
    }
    
    @IBAction private func deleteTask(_ sender: UIButton) {
        if let id = fileCache?.todoItems.first?.value.id {
            fileCache?.removeTask(withId: id)
        }
        guard let id = currentItem?.id else { return }
        rootVC?.fileCache.removeTask(withId: id)
    }
}
