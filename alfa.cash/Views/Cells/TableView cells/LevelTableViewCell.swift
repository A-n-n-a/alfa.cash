//
//  LevelTableViewCell.swift
//  alfa.cash
//
//  Created by Anna on 7/17/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class LevelTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var earnedLabel: UILabel!

    var level: Level! {
        didSet {
            setupCell()
        }
    }
    
    func setupCell() {
        titleLabel.text = level.title
        percentLabel.text = "\(level.percent)%"
        if let earning = level.earning {
            earnedLabel.text = "$\(earning)"
        }
        
        let isCurrent = ApplicationManager.referralInfo?.level.title == level.title
        let blue = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
        let white = ThemeManager.currentTheme.associatedObject.defaultBackgroundColor
        containerView.backgroundColor = isCurrent ? white : blue
        titleLabel.font = isCurrent ? titleLabel.font.semibold : titleLabel.font.medium
        percentLabel.font = isCurrent ? percentLabel.font.semibold : percentLabel.font.medium
        earnedLabel.font = isCurrent ? earnedLabel.font.semibold : earnedLabel.font.medium
    }
}
