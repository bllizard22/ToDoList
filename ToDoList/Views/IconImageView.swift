//
//  IconImageView.swift
//  ToDoList
//
//  Created by Nikolay Kryuchkov on 06.06.2021.
//

import UIKit

class IconImageView: UIImageView {

    override init(image: UIImage?) {
        super.init(image: image)
        
        setupIconView()
    }
    
    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
        super.init(coder: coder)
        
        setupIconView()
    }
    
    func setupIconView() {
        self.layer.cornerRadius = 30
//        self.clipsToBounds = true
    }
}
