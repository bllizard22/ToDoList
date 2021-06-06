//
//  ViewController.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 06.06.2021.
//

import UIKit

class ViewController: UIViewController {
    
    let buildModel = BuildVersionModel()

    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var buildLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let version = NSLocalizedString("Version", comment: "Version on About screen")
        let build = NSLocalizedString("Build", comment: "Build on About screen")
        buildLabel.text = version + " \(buildModel.versionNumber)\n" + build + " \(buildModel.buildNumber)"
        print(NSLocalizedString("debug print", comment: "debug"))
    }

}
