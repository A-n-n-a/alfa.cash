//
//  SettingsIconTableViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 28.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class SettingsIconTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: ACLabel!
    @IBOutlet weak var subtitleLabel: ACLabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var arrow: UIImageView!
    
    var model: SettingsItemModel! {
        didSet {
            arrow.isHidden = model.title == "CONNECT_TO_ALFACASH"
            titleLabel.setText(model.title)
            if let subtitle = model.subtitle {
                subtitleLabel.setText(subtitle)
            } else {
                subtitleLabel.isHidden = true
            }
            
            selectionStyle = .none
            let backColor = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
            contentView.backgroundColor = backColor
            
            if let image = model.image {
                icon.image = image
            }
        }
    }
}
