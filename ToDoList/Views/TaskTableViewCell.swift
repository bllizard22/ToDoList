//
//  TaskTableViewCell.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 19.06.2021.
//

import UIKit

class TaskTableViewCell: UITableViewCell {

    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = .disclosureIndicator
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func doneButtonDidPressed(_ sender: UIButton) {
        
    }
    
}
