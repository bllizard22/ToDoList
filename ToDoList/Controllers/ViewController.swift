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
        fileCache.loadFromFile()
    }

    @IBAction func readButtonDidTouched(_ sender: UIButton) {
        fileCache.loadFromFile()
    }
    
    @IBAction func writeButtonDidTouched(_ sender: Any) {
//        createItems()
        fileCache.saveToFile()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openTaskDetail" {
//            let detailVCType = UINavigationController().topViewController
            let destination = segue.destination as! UINavigationController
            let topVC = destination.topViewController as! DetailViewController
            topVC.fileCache = fileCache
        }
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
