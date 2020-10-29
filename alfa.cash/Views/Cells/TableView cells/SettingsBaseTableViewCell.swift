//
//  SettingsBaseTableViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 28.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class SettingsBaseTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: ACLabel!
    @IBOutlet weak var subtitleLabel: ACLabel!
    @IBOutlet weak var valueLabel: ACLabel!
    @IBOutlet weak var iconContainer: UIView!
    
    var model: SettingsItemModel! {
        didSet {
            titleLabel.setText(model.title)
            if let subtitle = model.subtitle {
                subtitleLabel.setText(subtitle)
            } else {
                subtitleLabel.isHidden = true
            }
            
            valueLabel.isHidden = false
            if let value = model.value {
                valueLabel.text = value
            } else {
                valueLabel.isHidden = true
            }
            
            iconContainer.isHidden = !model.valueBlack
            selectionStyle = .none
            let backColor = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
            contentView.backgroundColor = backColor
        }
    }
}
