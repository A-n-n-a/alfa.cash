//
//  NotificationTableViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 18.05.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class NotificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var coinLabel: TitleLabel!
    @IBOutlet weak var typeLabel: SubtitleLabel!
    @IBOutlet weak var dateLabel: SubtitleLabel!
    @IBOutlet weak var amountLabel: UILabel!
    
    var notification: ACNotification! {
        didSet {
            setupCell()
        }
    }
    
    func setupCell() {
        
        guard let wallet = WalletManager.wallets.filter( {$0.id == notification.walletId }).first else { return }
        
        let currencyName = wallet.currency == "erc20" ? "eth" : wallet.currency
        let iconName = ThemeManager.currentTheme == .trueNight ? "\(currencyName)_dark" : currencyName 
        icon.image = UIImage(named: iconName)
        
        coinLabel.text = wallet.currency.uppercased()
        typeLabel.text = notification.type == .receive ? "RECEIVED".localized() : "SENT".localized()
        dateLabel.text = notification.date.toString(format: Constants.DateFormats.transactionTime)
        
        var amountPrefix = "-"
        var color: UIColor = .kErrorColor
        
        if notification.type == .receive {
            amountPrefix = "+"
            color = .kTurquoiseColor
        }
        DispatchQueue.main.async {
            self.amountLabel.textColor = color
            self.amountLabel.text = "\(amountPrefix)\(self.notification.amount) \(wallet.currency.uppercased())"
        }
        
        let backColor = ThemeManager.currentTheme.associatedObject.defaultBackgroundColor
        contentView.backgroundColor = .clear
    }
}
