//
//  BuildModel.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 06.06.2021.
//

import Foundation

class BuildVersionModel {
    
    let buildNumber: String
    let versionNumber: String

    init() {
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        buildNumber = build ?? "0"

        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        versionNumber = version ?? "0"
    }
}
