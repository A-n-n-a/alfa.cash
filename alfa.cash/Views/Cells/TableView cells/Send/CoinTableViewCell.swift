//
//  CoinTableViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 24.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class CoinTableViewCell: UITableViewCell {

    @IBOutlet weak var coinTatleLabel: ACLabel!
    @IBOutlet weak var coinAmountLabel: ACLabel!
    @IBOutlet weak var moneyAmountLabel: ACLabel!
    @IBOutlet weak var currencyLabel: UILabel!
    
    var wallet: Wallet! {
        didSet {
            selectionStyle = .none
            coinTatleLabel.text = wallet.title
            coinAmountLabel.text = "\(wallet.amount) \(wallet.currency.uppercased())"
            moneyAmountLabel.text = wallet.money
            currencyLabel.text = wallet.currency.uppercased()
            backgroundColor = ThemeManager.currentTheme.associatedObject.cellBackgroundColor
        }
    }
}
