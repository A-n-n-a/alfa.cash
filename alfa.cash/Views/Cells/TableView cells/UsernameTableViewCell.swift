//
//  UsernameTableViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 28.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class UsernameTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: ACLabel!
    @IBOutlet weak var copyIcon: UIImageView!
    @IBOutlet weak var triangleIcon: UIImageView!
    
    var username: String? {
        didSet {
            if let username = username {
                usernameLabel.text = username
                copyIcon.isHidden = false
                triangleIcon.isHidden = true
            } else {
                usernameLabel.setText("ADD_USERNAME")
                copyIcon.isHidden = true
                triangleIcon.isHidden = false
            }
            
            let backColor = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
            contentView.backgroundColor = backColor
            selectionStyle = .none
        }
    }
    
    func copyName() {
        copyIcon.image = #imageLiteral(resourceName: "copy")
        UIPasteboard.general.string = username
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.copyIcon.image = #imageLiteral(resourceName: "copy_pale")
        }
    }
}
