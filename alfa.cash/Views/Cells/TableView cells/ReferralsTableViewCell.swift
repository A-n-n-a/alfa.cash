//
//  ReferralsTableViewCell.swift
//  alfa.cash
//
//  Created by Anna on 6/26/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class ReferralsTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: TitleLabel!
    @IBOutlet weak var amountLabel: SubtitleLabel!
    @IBOutlet weak var topSeparator: UIView!
    
    var referral: ReferralItem! {
        didSet {
            nameLabel.text = referral.name
            amountLabel.text = "\(referral.orders)"
        }
    }
    
    func setBackground(index: Int) {
        let blue = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
        let white = ThemeManager.currentTheme.associatedObject.defaultBackgroundColor
        backgroundColor = index % 2 == 0 ? blue :  white
        topSeparator.isHidden = index % 2 != 0
    }
}
