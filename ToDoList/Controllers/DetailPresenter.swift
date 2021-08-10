//
//  DetailPresenter.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 19.07.2021.
//

import Foundation
import PriorityEnum

class DetailPresenter {

    var detailVC: DetailViewController!

    init(controller: DetailViewController, fileCache: FileCache?, withTask item: TodoItem?) {
        self.detailVC = controller
        self.detailVC.currentItem = item
        self.detailVC.fileCache = fileCache
    }

    func saveTask(textRaw: String?, importance: Int, isDeadlineSwitchOn: Bool, date: Date) {
        guard let text = textRaw else { return }

        if let currentItem = detailVC.currentItem {
            let item = TodoItem(id: currentItem.id,
                                text: text,
                                importance: Priority(rawValue: importance)!,
                                deadline: isDeadlineSwitchOn ? date : nil,
                                isDone: currentItem.isDone)
            detailVC.fileCache?.updateTask(item, needToToggleDone: false)

        } else {
            let importance = Priority(rawValue: importance) ?? .moderate

            let deadline = isDeadlineSwitchOn ? date : nil

            let item: TodoItem = TodoItem(text: text,
                                          importance: importance,
                                          deadline: deadline)
            detailVC.fileCache?.addNewTask(item)
        }

        detailVC.closeDetailVC()
    }

}
