//
//  PinTableViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 19.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol PinTableViewCellDelegate {
    func appendWalletToPin(_ wallet: Wallet)
    func removeWalletToPin(id: Int)
}

class PinTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var amountLabel: TitleLabel!
    @IBOutlet weak var moneyLabel: SubtitleLabel!
    @IBOutlet weak var labelsStack: UIStackView!
    @IBOutlet weak var tagView: TagView!
    @IBOutlet weak var currencyLabel: TagLabel!
    
    var wallet: Wallet! {
        didSet {
            titleLabel.text = wallet.title
            amountLabel.text = "\(wallet.amount) \(wallet.currency.uppercased())"
            let currencyName = wallet.currency == "erc20" ? "eth" : wallet.currency
            let iconName = ThemeManager.currentTheme == .day ? currencyName : "\(currencyName)_dark"
            icon.image = UIImage(named: iconName)
            backgroundColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
            moneyLabel.text = wallet.money
            
            let bgColorView = UIView(frame: self.frame)
            bgColorView.backgroundColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
            selectedBackgroundView = bgColorView
            
        }
    }
    
    var currency: TopupCurrency! {
        didSet {
            titleLabel.text = currency.name
            let currencyName = currency.name == "erc20" ? "eth" : currency.sign
            currencyLabel.text = currencyName.uppercased()
            let iconName = ThemeManager.currentTheme == .day ? currencyName : "\(currencyName)_dark"
            icon.image = UIImage(named: iconName)
            backgroundColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
            
            let bgColorView = UIView(frame: self.frame)
            bgColorView.backgroundColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
            selectedBackgroundView = bgColorView
            
            labelsStack.isHidden = true
            tagView.isHidden = false
        }
    }
    
    var selectedToPin: Bool = false {
        didSet {
            backgroundColor = selectedToPin ? ThemeManager.currentTheme.associatedObject.cellSelectedBackgroundColor : ThemeManager.currentTheme.associatedObject.homePageToolBarColor
            if selectedToPin {
                delegate?.appendWalletToPin(wallet)
            } else {
                delegate?.removeWalletToPin(id: wallet.id)
            }
        }
    }
    
    var delegate: PinTableViewCellDelegate?
}
