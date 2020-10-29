//
//  SendInfoTableViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 04.03.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class SendInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: ACLabel!
    @IBOutlet weak var valueLabel: ACLabel!
    
    
    func setUpCell(title: String, value: String) {
        titleLabel.text = title
        valueLabel.text = value
        backgroundColor = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
    }
}
