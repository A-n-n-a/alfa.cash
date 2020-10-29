//
//  TransactionTableViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 17.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import TrustWalletCore

protocol TransactionTableViewCellDelegate {
    func makeSimilarPayment(wallet: Wallet, amount: String, account: String?, isTopup: Bool, destinationTag: Int?, memo: String?)
}

class TransactionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var typeLabel: TitleLabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var changedToLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var feeLabel: ACLabel!
    @IBOutlet weak var totalLabel: ACLabel!
    @IBOutlet weak var copyImage: UIImageView!
    @IBOutlet weak var transactionIdTextView: UITextView!
    @IBOutlet weak var pendingView: UIView!
    @IBOutlet weak var exchangeTag: UIView!
    @IBOutlet weak var pendingLabel: ACLabel!
    @IBOutlet weak var exchangeLabel: TagLabel!
    @IBOutlet weak var addressLabel: TitleLabel!
    
    var delegate: TransactionTableViewCellDelegate?
    
    var transaction: ACTransaction! {
        didSet {
            
            exchangeLabel.text = "EXCHANGE".localized().uppercased()
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
            
            feeLabel.text = transaction.fee
            totalLabel.text = getTotal()
            
            addressLabel.text = (transaction.toAddress?.isEmpty ?? true) ? transaction.login : transaction.toAddress
            if transaction.toAddress?.isEmpty ?? true && transaction.login == nil {
                addressLabel.text = "-"
            }
            
            setLink()
            
            pendingView.isHidden = transaction.status != .pending
            exchangeTag.isHidden = true
            exchangeTag.isHidden = transaction.type != .exchange
            
            typeLabel.textColor = ThemeManager.currentTheme.associatedObject.textColor
            dateLabel.textColor = ThemeManager.currentTheme.associatedObject.headerTextColor
            
        }
    }
    
    func getTotal() -> String {
        if let feeDouble = BDouble(transaction.fee), let amountDouble = BDouble( transaction.balanceChange) {
            let total = feeDouble + amountDouble
            if let afterDecimalPoint = total.description.components(separatedBy: "/").last {
                let afterPointCount = afterDecimalPoint.count - 1
                let totalString = total.decimalExpansion(precisionAfterDecimalPoint: afterPointCount)
                return totalString
            }
        }
        
        return ""
    }
    
    func setLink() {
        
        let attributedString = NSMutableAttributedString(string: transaction.hash)
        
        guard let coin = try? TrustWalletCore.CoinType.getCoin(from: transaction.currencyType), let link = coin.blockchainExplorerLink, let url = URL(string: link + transaction.hash) else { return }
        
        attributedString.setAttributes([.link: url], range: NSMakeRange(0, transaction.hash.count))

        transactionIdTextView.attributedText = attributedString
        transactionIdTextView.isUserInteractionEnabled = true
        transactionIdTextView.isEditable = false
        transactionIdTextView.textContainer.maximumNumberOfLines = 1

        // Set how links should appear: blue and underlined
        transactionIdTextView.linkTextAttributes = [
            .foregroundColor: UIColor.blue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: UIFont.systemFont(ofSize: 16)
        ]
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
    }
    
    @IBAction func copyTransactionId(_ sender: Any) {
        UIPasteboard.general.string = transaction.hash
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
            
            delegate?.makeSimilarPayment(wallet: wallet, amount: transaction.balanceChange, account: transaction.toAddress, isTopup: false, destinationTag: destTag, memo: memo)
        }
    }
}
