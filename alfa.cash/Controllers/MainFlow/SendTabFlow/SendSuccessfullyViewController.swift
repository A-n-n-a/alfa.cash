//
//  SendSuccessfullyViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 04.03.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import TrustWalletCore

class SendSuccessfullyViewController: BaseViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    
    var txId: String!
    var currency: TrustWalletCore.CoinType?
    var amount: String?
    var speed: Speed = .medium
    var fee: String = "0.00"
    var address = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cellClass: AmountTableViewCell.self)
        tableView.register(cellClass: SendInfoTableViewCell.self)
        playSound()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        tableViewHeight.constant = BDouble(fee) == 0 ? 235 : 310
    }
    
    func playSound() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SoundManager.play(soundType: .send)
        }
    }
    
    @IBAction func shareAction(_ sender: Any) {
        let activity = UIActivityViewController(activityItems: [address], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = self.view
        activity.popoverPresentationController?.sourceRect = CGRect(x: self.view.frame.width - 35, y: 50, width: 5, height: 5)
        
        self.present(activity, animated: true, completion: nil)
    }
    
    @IBAction func copyAction(_ sender: Any) {
        UIPasteboard.general.string = address
        let okAction = UIAlertAction(title: "OK".localized(), style: .cancel, handler: nil)
        self.showAlert(title: nil, message: "ADDRESS_COPIED".localized(), actions: [okAction])
    }
    
    @IBAction func goBack(_ sender: Any) {
        TransactionManager.shouldUpdateTransactions = true
        navigationController?.popViewController(animated: true)
    }
}

extension SendSuccessfullyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BDouble(fee) == 0 ? 3 :4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(AmountTableViewCell.self)) as! AmountTableViewCell
            cell.currency = currency
            cell.amount = amount
            return cell
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(SendInfoTableViewCell.self)) as! SendInfoTableViewCell
            var title = ""
            var value = ""
            switch indexPath.row {
            case 1:
                title = BDouble(fee) == 0 ? "TO".localized() : "NETWORK_FEE".localized()
                value = BDouble(fee) == 0 ? address : "\(fee) \(currency?.currency.uppercased() ?? "ERC20")"
            case 2:
                title = BDouble(fee) == 0 ? "TXID" :"TO".localized()
                value = BDouble(fee) == 0 ? txId : address
            case 3:
                if BDouble(fee) == 0 {
                    break
                } else {
                    title = "TXID"
                    value = txId
                }
            default: break
            }
            
            cell.setUpCell(title: title, value: value)
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 85
        }
        return 75
    }
}
