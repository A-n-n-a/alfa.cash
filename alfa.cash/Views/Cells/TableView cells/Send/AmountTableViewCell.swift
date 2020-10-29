//
//  AmountTableViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 24.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import TrustWalletCore


class AmountTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: ACLabel!
    @IBOutlet weak var currencyLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 0, height: 44))
    var amountIsValid = true
    
    var currency: CoinType? {
        didSet {

            currencyLabel.text = currency?.currency.uppercased() ?? "ERC20"
            
            let bgColorView = UIView(frame: self.frame)
            bgColorView.backgroundColor = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
            selectedBackgroundView = bgColorView
            
            contentView.backgroundColor = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
            
            selectionStyle = .none
        }
    }
    
    var amount: String? {
        didSet {
            setAmount(amount)
        }
    }
    
    func checkAmount(_ amount: String?) {
        if let address = amount {
            if address.isAmountValid() {
                contentView.backgroundColor = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
            } else {
                contentView.backgroundColor = UIColor.kErrorColor.withAlphaComponent(0.3)
            }
        } else {
            contentView.backgroundColor = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
        }
        setNeedsDisplay()
    }
    
    func setAmount(_ amount: String?) {
        if amount?.isEmpty ?? true {
            amountLabel.text = "0.00"
        } else {
            amountLabel.text = amount
        }
    }
}
