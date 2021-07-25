//
//  DetailViewController.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 13.06.2021.
//

import UIKit
import PriorityEnum

class DetailViewController: UIViewController, UITextViewDelegate {

    var fileCache: FileCache?
    var currentItem: TodoItem?
    var rootVC: ViewController?

    var detailPresenter: DetailPresenter!
    
    var deadlinePicker: UIDatePicker!
    var isSaveEnabled: Bool {
        textView.text != nil && textView.text != "" && textView.text != currentItem?.text
    }
    
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

        detailPresenter = DetailPresenter(controller: self,
                                          fileCache: fileCache,
                                          withTask: currentItem)
        
        setupVC()
        loadItem()
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
        
        textView.delegate = self
        
        deleteButton.isEnabled = currentItem != nil
    }
    
    private func loadItem() {
        guard let item = currentItem else { return }
        textView.text = item.text
        importanceSegmets.selectedSegmentIndex = item.importance.rawValue
        
        if item.deadline != nil {
            deadlineSwitch.isOn = true
            showDeadlinePicker()
            let date = item.deadline ?? Date()
            deadlinePicker.setDate(date, animated: true)
        }
    }

    @IBAction private func cancelAction(_ sender: UIBarButtonItem) {
        closeDetailVC()
    }

    @IBAction private func saveTask(_ sender: UIBarButtonItem) {
        detailPresenter.saveTask(textRaw: textView.text,
                                 importance: importanceSegmets.selectedSegmentIndex,
                                 isDeadlineSwitchOn: deadlineSwitch.isOn,
                                 date: deadlinePicker.date)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = isSaveEnabled
    }
    
    func showDeadlinePicker() {
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
    }
    
    @IBAction private func deadlineSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            showDeadlinePicker()
        } else {
            settingsViewHeightConstraint.constant -= deadlinePicker.frame.height + settingsStack.spacing

            deadlinePicker.removeFromSuperview()
            settingsView.setNeedsLayout()
        }

    }
    
    @IBAction private func deleteTask(_ sender: UIButton) {
        guard let id = currentItem?.id else { return }
        fileCache?.removeTask(withId: id)
        
        closeDetailVC()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    func closeDetailVC() {
        dismiss(animated: true) { [ weak self ] in
            self?.rootVC?.reloadTasksTableView()
        }
    }
}
