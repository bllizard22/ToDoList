//
//  TasksTableView.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 19.06.2021.
//

import UIKit

class TasksTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        configureTableView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureTableView()
    }
    
    func configureTableView() {
        self.layer.cornerRadius = 16
        self.clipsToBounds = true
        self.rowHeight = 56
//        self.estimatedRowHeight = 200
//        self.rowHeight = UITableView.automaticDimension
        
        self.tableFooterView = UITableViewCell(style: .default, reuseIdentifier: "cell")
    }

}
