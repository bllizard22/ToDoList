//
//  ViewController.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 06.06.2021.
//

import UIKit

class ViewController: UIViewController {
    
//    let buildModel = BuildVersionModel()
//    let fileCache = FileCache()
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

        let version = NSLocalizedString("Version", comment: "Version on About screen")
        let build = NSLocalizedString("Build", comment: "Build on About screen")
        buildLabel.text = version + " \(buildModel.versionNumber)\n" + build + " \(buildModel.buildNumber)"
        print(NSLocalizedString("debug print", comment: "debug"))

    }

    @IBAction func readButtonDidTouched(_ sender: UIButton) {
        fileCache.loadFromFile()
    }
    
    @IBAction func writeButtonDidTouched(_ sender: Any) {
        fileCache.saveToFile()
    }
    
    func createOneItem() {

        let item = TodoItem(text: "sell smth",
                            importance: .high,
                            deadline: Date().timeIntervalSince1970 + 3600*24*7)
        print(item)
        
        let item2 = TodoItem(text: "buy smth", importance: .moderate)
        print(item2)
        
//        try? FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories:
//        true, attributes: nil)
//
//        let fm = FileManager.default
//        let path = Bundle.main.resourcePath!
//
//        let dir = NSTemporaryDirectory()
//        do {
//            let items = try fm.contentsOfDirectory(atPath: dir)
//
//            for item in items {
//                print("Found \(item)")
//            }
//        } catch {
//            // failed to read directory – bad permissions, perhaps?
//        }
        
    }
    
}
