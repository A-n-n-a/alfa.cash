//
//  ReferralDetailsViewController.swift
//  alfa.cash
//
//  Created by Anna on 7/1/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import WebKit

class ReferralDetailsViewController: BaseViewController {

    @IBOutlet weak var incomeHistoryLabel: SelectionLabel!
    @IBOutlet weak var referralsLabel: SelectionLabel!
    @IBOutlet weak var termsLabel: SelectionLabel!
    @IBOutlet weak var amountLabel: TitleLabel!
    @IBOutlet weak var termsView: UIView!
    
    @IBOutlet weak var incomeHistoryTableView: UITableView!
    @IBOutlet weak var referralsTableView: UITableView!
    @IBOutlet weak var headerView: ACBackgroundView!
    @IBOutlet weak var incomesUnderscoreView: UIView!
    @IBOutlet weak var referralsUnderscoreView: UIView!
    @IBOutlet weak var termsUnderscoreView: UIView!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let historyBackground = TableBackgroundView()
    let referralBackground = TableBackgroundView()
    var histories: [IncomeHistory] = [] {
        didSet {
            historyBackground.alpha = histories.isEmpty ? 1 : 0
            headerView.alpha = histories.isEmpty ? 0 : 1
            incomeHistoryTableView.reloadData()
        }
    }
    
    var referrals: [ReferralItem] = [] {
        didSet {
            referralBackground.alpha = histories.isEmpty ? 1 : 0
            headerView.alpha = referrals.isEmpty ? 0 : 1
            referralsTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpHomeNavBar(title: "SETTINGS_REFER_EARN")
        setupBackground()
        
        incomeHistoryTableView.register(cellClass: IncomeHistoryTableViewCell.self)
        referralsTableView.register(cellClass: ReferralsTableViewCell.self)
        
        getIncomes()
        getReferrals()
        setupWebView()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setupWebView() {
        webView.navigationDelegate = self
        let link = Constants.Link.referral
        if let url = URL(string: link), let request = WebViewManager.shared.createRequest(url) {
            activityIndicator.startAnimating()
            webView.load(request)
        }
    }
    
    func setupBackground() {
        historyBackground.setupWithTitle("NO_HISTORY_FOUND".localized(), subtitle: "KEEP_TRACK_YOUR_COMMISIONS".localized())
        historyBackground.hideIcon()
        incomeHistoryTableView.backgroundView = historyBackground
        
        referralBackground.setupWithTitle("NO_HISTORY_FOUND".localized(), subtitle: "KEEP_TRACK_YOUR_COMMISIONS".localized())
        referralBackground.hideIcon()
        referralsTableView.backgroundView = referralBackground
    }
    
    func getIncomes() {
        NetworkManager.getReferralIncome { [weak self] (history, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if let history = history {
                    self?.histories = history
                }
            }
        }
    }
    
    func getReferrals() {
        NetworkManager.getReferrals { [weak self] (referrals, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showError(error)
                }
                if let referrals = referrals {
                    self?.referrals = referrals
                }
            }
        }
    }
    
    @IBAction func incomeHistoryAction(_ sender: Any) {
        incomeHistoryLabel.setSelected(true)
        referralsLabel.setSelected(false)
        termsLabel.setSelected(false)
        incomeHistoryTableView.isHidden = false
        referralsTableView.isHidden = true
        termsView.isHidden = true
        headerView.alpha = 1
        amountLabel.text = "AMOUND_USD".localized()
        
        incomesUnderscoreView.isHidden = false
        referralsUnderscoreView.isHidden = true
        termsUnderscoreView.isHidden = true
        
    }
    
    @IBAction func referralsAction(_ sender: Any) {
        incomeHistoryLabel.setSelected(false)
        referralsLabel.setSelected(true)
        termsLabel.setSelected(false)
        incomeHistoryTableView.isHidden = true
        referralsTableView.isHidden = false
        termsView.isHidden = true
        headerView.alpha = 1
        amountLabel.text = "ORDERS".localized()
        
        incomesUnderscoreView.isHidden = true
        referralsUnderscoreView.isHidden = false
        termsUnderscoreView.isHidden = true
    }
    
    @IBAction func termsAction(_ sender: Any) {
        incomeHistoryLabel.setSelected(false)
        referralsLabel.setSelected(false)
        termsLabel.setSelected(true)
        incomeHistoryTableView.isHidden = true
        referralsTableView.isHidden = true
        termsView.isHidden = false
        headerView.alpha = 0
        
        incomesUnderscoreView.isHidden = true
        referralsUnderscoreView.isHidden = true
        termsUnderscoreView.isHidden = false
    }
    
}

extension ReferralDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView == incomeHistoryTableView ? histories.count : referrals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == incomeHistoryTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(IncomeHistoryTableViewCell.self)) as! IncomeHistoryTableViewCell
            cell.history = histories[indexPath.row]
            cell.setBackground(index: indexPath.row)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(ReferralsTableViewCell.self)) as! ReferralsTableViewCell
            cell.referral = referrals[indexPath.row]
            cell.setBackground(index: indexPath.row)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch tableView {
        case incomeHistoryTableView:
            return true
        default:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let history = histories[indexPath.row]
        let title = history.date.toString(format: Constants.DateFormats.referralSwipeFormat)
        let contextItem = UIContextualAction(style: .destructive, title: title) {  (contextualAction, view, boolValue) in
            //Code I want to do here
        }
        
        contextItem.backgroundColor = UIColor.kButtonColor
        
        let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])

        return swipeActions
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? IncomeHistoryTableViewCell {
            cell.cellDidSwipe(true)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        if let cell = tableView.cellForRow(at: indexPath) as? IncomeHistoryTableViewCell {
            cell.cellDidSwipe(false)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset.y = 0
        }
    }
}

extension ReferralDetailsViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        activityIndicator.stopAnimating()
        self.showError(error)
    }
}
