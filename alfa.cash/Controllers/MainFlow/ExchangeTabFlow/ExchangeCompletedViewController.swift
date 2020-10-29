//
//  ExchangeCompletedViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 02.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class ExchangeCompletedViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var txId: String!
    var address = ""
    var walletTo: Wallet?
    var amountTo: String?
    var rate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cellClass: AmountTableViewCell.self)
        tableView.register(cellClass: SendInfoTableViewCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
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

extension ExchangeCompletedViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(AmountTableViewCell.self)) as! AmountTableViewCell
            cell.currency = TransactionManager.transactionHeaders.currency
            cell.amount = TransactionManager.transactionHeaders.amount
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(AmountTableViewCell.self)) as! AmountTableViewCell
            if let wallet = walletTo {
                cell.currency = wallet.coin
            }
            if let amount = amountTo {
                cell.amount = amount
            }
            return cell
        default:
            
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(SendInfoTableViewCell.self)) as! SendInfoTableViewCell
            var title = ""
            var value = ""
            switch indexPath.row {
            case 2:
                title = "NETWORK_FEE".localized()
                value = "\(TransactionManager.transactionHeaders.fee) \(TransactionManager.transactionHeaders.currency?.currency.uppercased() ?? "ERC20")"
            case 3:
                title = "TO".localized()
                value = address
            case 4:
                title = "TXID"
                value = txId
            default: break
            }
            
            cell.setUpCell(title: title, value: value)
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 || indexPath.row == 1 {
            return 80
        }
        return 75
    }
}
