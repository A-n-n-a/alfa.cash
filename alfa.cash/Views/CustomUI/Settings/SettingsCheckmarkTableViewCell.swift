//
//  SettingsCheckmarkTableViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 29.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class SettingsCheckmarkTableViewCell: UITableViewCell {

     override func awakeFromNib() {
           super.awakeFromNib()
           self.theme.backgroundColor = ThemeManager.shared.themed( { $0.cellBackgroundSettingsColor })
       }
}
