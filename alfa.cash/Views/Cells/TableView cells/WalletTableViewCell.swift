//
//  WalletTableViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 05.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: TitleLabel!
    @IBOutlet weak var amountLabel: TitleLabel!
    @IBOutlet weak var moneyLabel: SubtitleLabel!
    @IBOutlet weak var labelsStack: UIStackView!
    
    var wallet: Wallet! {
        didSet {
            titleLabel.text = wallet.title
            amountLabel.text = "\(wallet.amount) \(wallet.currency.uppercased())"
            let currencyName = wallet.currency == "erc20" ? "eth" : wallet.currency
            let iconName = ThemeManager.currentTheme == .trueNight ?"\(currencyName)_dark" : currencyName 
            icon.image = UIImage(named: iconName)
            labelsStack.isHidden = false
            moneyLabel.text = wallet.money
            setUpLabels()
        }
    }
    
    var cellActionButtonLabel: UILabel? {
        for subview in self.superview?.subviews ?? [] {
            if String(describing: subview).range(of: "UISwipeActionPullView") != nil {
                for view in subview.subviews {
                    if String(describing: view).range(of: "UISwipeActionStandardButton") != nil {
                        for sub in view.subviews {
                            if let label = sub as? UILabel {
                                return label
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
    
    func setUpLabels() {
        let backColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
        let textThemedColor = ThemeManager.currentTheme.associatedObject.textColor
        let headerColor = ThemeManager.currentTheme.associatedObject.headerTextColor
        titleLabel.textColor = textThemedColor
        amountLabel.textColor = textThemedColor
        moneyLabel.textColor = headerColor
        backgroundColor = backColor
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        cellActionButtonLabel?.textColor = ThemeManager.currentTheme.associatedObject.textColor
    }
    
    func cellDidSwipe(_ swiped: Bool) {
        backgroundColor = swiped ? .kPinRowColor : ThemeManager.currentTheme.associatedObject.homePageToolBarColor
    }
    
    func setUpAddCoin() {
        titleLabel.text = "ADD_COIN".localized()
        labelsStack.isHidden = true
        icon.image = #imageLiteral(resourceName: "pin")
        backgroundColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
        titleLabel.textColor = ThemeManager.currentTheme.associatedObject.textColor
    }
}
