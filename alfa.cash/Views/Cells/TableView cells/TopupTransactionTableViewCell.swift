//
//  TopupTransactionTableViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 17.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import TrustWalletCore

class TopupTransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var typeLabel: TitleLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var changedToLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var feeTitle: SubtitleLabel!
    @IBOutlet weak var feeLabel: ACLabel!
    @IBOutlet weak var totalTitle: SubtitleLabel!
    @IBOutlet weak var totalLabel: ACLabel!
    @IBOutlet weak var copyImage: UIImageView!
    
    @IBOutlet weak var pendingView: UIView!
    @IBOutlet weak var pendingLabel: ACLabel!
    
    var delegate: TransactionTableViewCellDelegate?
    
    var transaction: ACTransaction! {
        didSet {
            
            pendingLabel.text = "PENDING".localized().uppercased()
            
            copyImage.image = UIPasteboard.general.string == transaction.hash ? #imageLiteral(resourceName: "copy") : #imageLiteral(resourceName: "copy_pale")
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
            
            let backColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
            contentView.backgroundColor = backColor
            
            if ThemeManager.currentTheme == .day {
                contentView.backgroundColor = transaction.expanded ? UIColor.kCellBackgroundDay : .white
            }
            
            pendingView.isHidden = transaction.status != .pending
            
            typeLabel.textColor = ThemeManager.currentTheme.associatedObject.textColor
            dateLabel.textColor = ThemeManager.currentTheme.associatedObject.headerTextColor
            
            
            feeLabel.text = transaction.additional?.orderId
            totalLabel.text = transaction.additional?.topupPhone
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    @IBAction func copyTransactionId(_ sender: Any) {
        UIPasteboard.general.string = transaction.additional?.orderId
        copyImage.image = #imageLiteral(resourceName: "copy")
    }
    
    @IBAction func makeSimilarPayment(_ sender: Any) {
        if let wallet = WalletManager.wallets.filter({$0.id == transaction.walletId}).first {
            
            var destTag: Int?
            var memo: String?
            if let tag = transaction.additional?.paymentTag {
                if let dest = Int(tag) {
                    destTag = dest
                } else if !tag.isEmpty {
                    memo = tag
                }
            }
            delegate?.makeSimilarPayment(wallet: wallet, amount: transaction.balanceChange, account: transaction.toAddress, isTopup: true, destinationTag: destTag, memo: memo)
        }
    }
}
