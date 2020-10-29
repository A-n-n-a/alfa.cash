//
//  PayoutHistoryTableViewCell.swift
//  alfa.cash
//
//  Created by Anna on 6/26/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class PayoutHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: TitleLabel!
    @IBOutlet weak var pendingLabel: UILabel!
    @IBOutlet weak var amountLabel: SubtitleLabel!
    @IBOutlet weak var topSeparator: UIView!
    
    var payment: ReferralPayment! {
        didSet {
            dateLabel.text = payment.timeCreated.toString(format: Constants.DateFormats.transactionTime)
            amountLabel.text = "\(payment.amountUsd) USD"
            pendingLabel.isHidden = payment.status != 0
        }
    }
    
    func setBackground(index: Int) {
        let blue = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
        let white = ThemeManager.currentTheme.associatedObject.defaultBackgroundColor
        backgroundColor = index % 2 == 0 ? blue :  white
        topSeparator.isHidden = index % 2 != 0
    }
}
