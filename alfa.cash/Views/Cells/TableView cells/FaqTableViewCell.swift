//
//  FaqTableViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 06.05.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class FaqTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: TitleLabel!
    @IBOutlet weak var subtitleLabel: SubtitleLabel!
    
    func setUpBackground() {
        let backColor = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
        contentView.backgroundColor = backColor
        selectionStyle = .none
    }
    
}
