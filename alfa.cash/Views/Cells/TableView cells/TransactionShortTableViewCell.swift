//
//  TransactionTableViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 17.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import TrustWalletCore

class TransactionShortTableViewCell: UITableViewCell {
    
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var changedToLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var pendingView: UIView!
    @IBOutlet weak var pendingLabel: ACLabel!
    @IBOutlet weak var exchangeTag: UIView!
    @IBOutlet weak var exchangeLabel: TagLabel!
    
    var transaction: ACTransaction! {
        didSet {
            
            pendingLabel.text = "PENDING".localized().uppercased()
            exchangeLabel.text = "EXCHANGE".localized().uppercased()
            
            typeLabel.text = transaction.type.label
            dateLabel.text = transaction.time.toString(format: Constants.DateFormats.transactionTime)
            var amountText = "-"
            var color: UIColor = .kErrorColor
            
            if transaction.type == .receive {
                amountText = "+"
                color = .kTurquoiseColor
            }
            DispatchQueue.main.async {
                self.amountLabel.textColor = color
            }

            amountText += "\(transaction.balanceChange) \(transaction.currencyType.uppercased())"
            amountLabel.text = amountText
            
            pendingView.isHidden = transaction.status != .pending
            
            let backColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
            contentView.backgroundColor = backColor
            
            exchangeTag.isHidden = transaction.type != .exchange
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
}
