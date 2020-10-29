//
//  IndicatorTableViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 20.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import  RxTheme

class IndicatorTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
//        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.cellBackgroundColor })
        selectionStyle = .none
    }
}

