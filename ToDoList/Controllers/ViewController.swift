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

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var buildLabel: UILabel!

    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var writeButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        buildModel = BuildVersionModel()
        fileCache = FileCache(forFile: "defaultList.txt")

//        let version = NSLocalizedString("Version", comment: "Version on About screen")
//        let build = NSLocalizedString("Build", comment: "Build on About screen")
//        buildLabel.text = version + " \(buildModel.versionNumber)\n" + build + " \(buildModel.buildNumber)"
//        print(NSLocalizedString("debug print", comment: "debug"))

    }

    @IBAction func readButtonDidTouched(_ sender: UIButton) {
        fileCache.loadFromFile()
    }
    
    @IBAction func writeButtonDidTouched(_ sender: Any) {
        createItems()
        fileCache.saveToFile()
    }
    
    // MARK: - create tasks for debug purposes
    func createItems() {

        let item = TodoItem(text: "sell smth",
                            importance: .high,
                            deadline: Date().timeIntervalSince1970 + 3600*24*7)
        fileCache.addNewTask(task: item)
        
        let item2 = TodoItem(text: "buy smth", importance: .moderate)
        fileCache.addNewTask(task: item2)
        
        let item3 = TodoItem(text: "buy 3 smth", importance: .moderate)
        fileCache.addNewTask(task: item3)
        fileCache.removeTask(withId: item3.id)
        
    }
    
}
