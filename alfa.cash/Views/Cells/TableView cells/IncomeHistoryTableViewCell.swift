//
//  IncomeHistoryTableViewCell.swift
//  alfa.cash
//
//  Created by Anna on 6/26/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class IncomeHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: TitleLabel!
    @IBOutlet weak var amountLabel: SubtitleLabel!
    @IBOutlet weak var topSeparator: UIView!
    @IBOutlet weak var blueView: UIView!
    @IBOutlet weak var calendarIcon: UIImageView!
    
    var history: IncomeHistory! {
        didSet {
            nameLabel.text = history.name
            amountLabel.text = "\(history.amount) USD"
        }
    }
    
    func setBackground(index: Int) {
        let blue = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
        let white = ThemeManager.currentTheme.associatedObject.defaultBackgroundColor
        backgroundColor = index % 2 == 0 ? blue :  white
        blueView.backgroundColor = .clear
        topSeparator.isHidden = index % 2 != 0
    }
    
    func cellDidSwipe(_ swiped: Bool) {
        calendarIcon.image = swiped ? #imageLiteral(resourceName: "calendar_white") : #imageLiteral(resourceName: "calendar_grey")
        blueView.backgroundColor = swiped ? .kButtonColor : .clear
    }
}
