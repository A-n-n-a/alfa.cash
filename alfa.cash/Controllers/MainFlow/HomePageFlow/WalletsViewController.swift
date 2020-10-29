//
//  WalletsViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 23.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol WalletsViewControllerDelegate {
    func showWallets(_ open: Bool)
    func showPinDialog(_ show: Bool)
    func updateBalance()
    func updateProfile()
    func setOffsetUp(_ offset: CGFloat)
    func setOffsetDown(_ offset: CGFloat)
}

class WalletsViewController: BaseViewController {

    @IBOutlet weak var walletsTableView: UITableView!
    @IBOutlet weak var topIcon: UIImageView!
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var walletsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var historyTableView: UITableView!
    @IBOutlet weak var historyTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var chartsTableView: UITableView!
    @IBOutlet weak var chartsTableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var backgroundView = TableBackgroundView()
    var historyBackgroundView = TableBackgroundView()
    var chartsBackgroundView = TableBackgroundView()
    var walletsRefreshControl = UIRefreshControl()
    var historyRefreshControl = UIRefreshControl()
    
    var delegate: WalletsViewControllerDelegate?
    var isExpanded = Bool()
    
    var currentPage = 0
    var isFetchInProgress = false
    
    var updatingEnable = true
    var previousTransactionsCount = 20
    var standardCellHeight: CGFloat = 64
    var topupCellHeight: CGFloat = 207
    var recieveCellHeight: CGFloat = 270
    var sendCellHeight: CGFloat = 312
    
    var chartsDataSource: [Wallet] {
        return WalletManager.pinnedWallets.filter({$0.currency != "erc20" })
    }
    
    var isRefreshing = false
    var currentTable: CurrentTable = .wallets
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addRefresh()
        walletsTableView.register(cellClass: WalletTableViewCell.self)
        historyTableView.register(cellClass: TransactionTableViewCell.self)
        historyTableView.register(cellClass: TopupTransactionTableViewCell.self)
        chartsTableView.register(cellClass: WalletChartTableViewCell.self)
        historyTableView.estimatedRowHeight = standardCellHeight
        setupBackground()
        updateBackground()
        isExpanded = false
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateWallets), name: NSNotification.Name.walletsUpdate, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let toolBarColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
        view.backgroundColor = toolBarColor
        walletsTableView.backgroundColor = toolBarColor
        historyTableView.backgroundColor = toolBarColor
        gestureView.backgroundColor = toolBarColor
        walletsTableView.reloadData()
        historyTableView.reloadData()
        
        if TransactionManager.shouldUpdateTransactions {
            getTransactions()
            TransactionManager.shouldUpdateTransactions = false
        }
        
        walletsRefreshControl.tintColor = ThemeManager.currentTheme == .day ? .black : .white
        historyRefreshControl.tintColor = ThemeManager.currentTheme == .day ? .black : .white
        
        backgroundView.setIconTintColor()
        historyBackgroundView.setIconTintColor()
        chartsBackgroundView.setIconTintColor()
        
        chartsTableView.backgroundColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
    }
    
    func addRefresh() {
        
        walletsRefreshControl.addTarget(self, action: #selector(retrieveWallets), for: .valueChanged)
        walletsTableView.refreshControl = walletsRefreshControl
        historyRefreshControl.addTarget(self, action: #selector(refreshHistory), for: .valueChanged)
        historyTableView.refreshControl = historyRefreshControl
        historyTableView.prefetchDataSource = self

    }
    
    @objc func updateWallets() {
        walletsTableView.reloadData()
    }
    
    @objc func refreshHistory() {
        updateHistory(refresh: true)
    }
    
    @objc func updateHistory(page: Int = 0, refresh: Bool = false) {
        currentPage = page
        if page == 0 {
            updatingEnable = true
        }
        var shouldFilterExchange = false
        var shouldExceptExchange = false
        var type: TransactionType?
        var currency: String?
        var timeFilter: FiltersSubtype?
        for filter in TransactionManager.filters {
            switch filter.type {
            case .time:
                timeFilter = filter.subType
            case .type:
                print(filter.subType.name)
                switch filter.subType {
                case .send:
                    type = .send
                    shouldExceptExchange = true
                case .receive:
                    type = .receive
                    shouldExceptExchange = true
                case .exchange:
                    type = .send
                    shouldFilterExchange = true
                default:
                    break
                }
            case .coin:
                currency = filter.currency
            }
        }
        
        getTransactions(page: page, type: type, currency: currency, completion: {
            self.applyFiltersToSearchResults(shouldFilterExchange: shouldFilterExchange, shouldExceptExchange: shouldExceptExchange, timeFilter: timeFilter)
            if TransactionManager.transactions.count == self.previousTransactionsCount, !refresh {
                self.updatingEnable = false
            } else {
                self.previousTransactionsCount = TransactionManager.transactions.count
            }
            self.historyTableView.reloadData()
            self.historyRefreshControl.endRefreshing()
            self.isRefreshing = false
              
            let pageCount = 20
            let startIndex = TransactionManager.transactions.count - pageCount
            let endIndex = startIndex + pageCount - 1
            let newIndexPaths = (startIndex...endIndex).map { i in
                return IndexPath(row: i, section: 0)
            }
            var visibleIndexPaths = self.historyTableView.indexPathsForVisibleRows ?? []
            visibleIndexPaths.append(contentsOf: newIndexPaths)
            let indexPathsNeedingReload = Set(visibleIndexPaths)

            self.historyTableView.beginUpdates()
            self.historyTableView.reloadRows(at: Array(indexPathsNeedingReload), with: .none)
            self.historyTableView.endUpdates()
            self.updateBackground()
        })
    }
    
    func applyFiltersToSearchResults(shouldFilterExchange: Bool, shouldExceptExchange: Bool, timeFilter: FiltersSubtype?) {
        self.historyRefreshControl.endRefreshing()
        self.isRefreshing = false
        if shouldFilterExchange || shouldExceptExchange {
            TransactionManager.transactions = TransactionManager.transactions.filter({ (transaction) -> Bool in
                if transaction.type == .exchange {
                    return shouldFilterExchange
                }
                if shouldFilterExchange {
                    return false
                }
                return true
            })
        }
        
        if let timeFilter = timeFilter {
            let currentDate = Date()
            var dateComponent = DateComponents()
            switch timeFilter {
            case .week:
                dateComponent.day = -7
            case .month:
                dateComponent.month = -1
            default:
                dateComponent.year = -1
            }
            
            if let pastDate = Calendar.current.date(byAdding: dateComponent, to: currentDate) {
                TransactionManager.transactions = TransactionManager.transactions.filter({ (transaction) -> Bool in
                    return transaction.time > pastDate
                })
            }
        }
        self.updateBackground()
        self.historyTableView.reloadData()
    }
    
    func updateGestures() {
        removeGestures()
        
        let closeSwipe = UISwipeGestureRecognizer(target: self, action: #selector(closeWallets))
        closeSwipe.direction = .down
        
        let openSwipe = UISwipeGestureRecognizer(target: self, action: #selector(openWallets))
        openSwipe.direction = .up
        
        let gesture = isExpanded ? closeSwipe : openSwipe
        gestureView.addGestureRecognizer(gesture)
        
        let image = isExpanded ? #imageLiteral(resourceName: "triangle") : #imageLiteral(resourceName: "rectangle")
        topIcon.image = image
    }
    
    func removeGestures() {
        guard let gestures = gestureView.gestureRecognizers else { return }
        for gesture in gestures {
            gestureView.removeGestureRecognizer(gesture)
        }
    }
    
    @objc func openWallets() {
        delegate?.showWallets(true)
        isExpanded = true
    }
    
    @objc func closeWallets() {
        delegate?.showWallets(false)
        isExpanded = false
    }
    
    func setTableViewHeight(_ height: CGFloat) {
        walletsTableViewHeight.constant = height
        historyTableViewHeight.constant = height
        chartsTableViewHeight.constant = height
//        UIView.animate(withDuration: 0.05) {
            self.view.layoutIfNeeded()
//        }
    }
    
    func showWallets() {
        walletsTableView.isHidden = false
        historyTableView.isHidden = true
        chartsTableView.isHidden = true
    }
    
    func showHistory() {
        historyTableView.reloadData()
        walletsTableView.isHidden = true
        historyTableView.isHidden = false
        chartsTableView.isHidden = true
    }
    
    func showCharts() {
        chartsTableView.reloadData()
        walletsTableView.isHidden.toggle()
        historyTableView.isHidden.toggle()
        chartsTableView.isHidden.toggle()
    }
    
    func pinWallet(id: Int, pin: Bool, completion: ((Bool) -> Void)?) {
        activityIndicator.startAnimating()
        NetworkManager.pinWallet(id: id, pin: pin) { [weak self] (success, error) in
            DispatchQueue.main.async {
                if let error = error {
                    self?.activityIndicator.stopAnimating()
                    self?.showError(error)
                    completion?(false)
                }
                if success {
                    completion?(true)
                }
            }
        }
    }
    
    @objc func retrieveWallets() {
        if ApplicationManager.profile == nil {
            delegate?.updateProfile()
        }
        getWallets { [weak self] (success) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.walletsRefreshControl.endRefreshing()
                self?.walletsTableView.setContentOffset(CGPoint.zero, animated: true)
                self?.isRefreshing = false
                if success {
                    self?.updateBackground()
                    self?.delegate?.updateBalance()
                }
            }
        }
    }
    
    func setupBackground() {
        backgroundView.delegate = self
        walletsTableView.backgroundView = backgroundView
        
        historyBackgroundView.setupWithTitle("NO_TRANSACTIONS_FOUND".localized())
        historyTableView.backgroundView = historyBackgroundView
        
        chartsBackgroundView.setupWithTitle("NO_COINS_FOUND".localized())
        chartsTableView.backgroundView = chartsBackgroundView
        chartsTableView.backgroundColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
    }
    
    func updateBackground() {
        
        backgroundView.alpha = WalletManager.pinnedWallets.isEmpty ? 1 : 0
        historyBackgroundView.alpha = TransactionManager.transactions.isEmpty ? 1 : 0
        chartsBackgroundView.alpha = WalletManager.pinnedWallets.isEmpty ? 1 : 0
        
    }
}

extension WalletsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableView == walletsTableView ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            switch tableView {
            case historyTableView:
                return TransactionManager.transactions.count
            case walletsTableView:
                return WalletManager.pinnedWallets.count
            case chartsTableView:
                return chartsDataSource.count
            default:
                return 0
            }
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case walletsTableView:
            if indexPath.section == 0  {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(WalletTableViewCell.self)) as! WalletTableViewCell
            cell.wallet = WalletManager.pinnedWallets[indexPath.row]
            return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellId(WalletTableViewCell.self)) as! WalletTableViewCell
                cell.setUpAddCoin()
                return cell
            }
        case historyTableView:
            let transaction = TransactionManager.transactions[indexPath.row]
            if transaction.type == .topup {
                let cell = tableView.dequeueReusableCell(withIdentifier: cellId(TopupTransactionTableViewCell.self)) as! TopupTransactionTableViewCell
                cell.transaction = transaction
                cell.delegate = self
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(TransactionTableViewCell.self)) as! TransactionTableViewCell
            cell.transaction = transaction
            cell.delegate = self
            return cell
        case chartsTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: cellId(WalletChartTableViewCell.self)) as! WalletChartTableViewCell
            cell.wallet = chartsDataSource[indexPath.row]
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch tableView {
        case walletsTableView:
            if indexPath.section == 0 {
                return standardCellHeight
            } else {
                if WalletManager.pinnedWallets.isEmpty || WalletManager.pinnedWallets.count == WalletManager.wallets.count {
                    return 0
                }
                return standardCellHeight
            }
        case historyTableView:
            let transaction = TransactionManager.transactions[indexPath.row]
            if transaction.expanded {
                switch transaction.type {
                case .topup:
                    return topupCellHeight
                case .send, .exchange:
                    return sendCellHeight
                case .receive:
                    return recieveCellHeight
                }
            } else {
                return standardCellHeight
            }
        default:
            return 280
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch tableView {
        case historyTableView, chartsTableView:
            return false
        default:
            return indexPath.section == 0
        }
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard tableView == walletsTableView, indexPath.section == 0 else {
            return nil
        }
        let delete = UITableViewRowAction(style: .destructive, title: "UNPIN".localized()) { (action, indexPath) in
            let walletId = WalletManager.pinnedWallets[indexPath.row].id
            self.pinWallet(id: walletId, pin: false) { [weak self] (success) in
                DispatchQueue.main.async {
                    if success, indexPath.row < WalletManager.pinnedWallets.count {
                        WalletManager.pinnedWallets.remove(at: indexPath.row)
                        if tableView.cellForRow(at: indexPath) != nil {
                            tableView.deleteRows(at: [indexPath], with: .middle)
                        }
                        self?.retrieveWallets()
                    }
                }
            }
        }

        delete.backgroundColor = UIColor.kPinButtonColor

        return [delete]
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? WalletTableViewCell {
            cell.cellDidSwipe(true)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        if let cell = tableView.cellForRow(at: indexPath) as? WalletTableViewCell {
            cell.cellDidSwipe(false)
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if tableView == walletsTableView {
            if indexPath.section == 1 {
                addCoin()
            } else {
                let wallet = WalletManager.pinnedWallets[indexPath.row]
                if let coinPageVC = UIStoryboard.get(flow: .coinPage).get(controller: .coinPageVC) as? CoinPageViewController {
                    coinPageVC.wallet = wallet
                    navigationController?.pushViewController(coinPageVC, animated: true)
                }
            }
        } else {
            shrinkTransactions(indexPath: indexPath)
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .none)
            tableView.endUpdates()
            
            let rowRect = tableView.rectForRow(at: indexPath)
            if rowRect.height != standardCellHeight {
                scrollCellIfNeeded(indexPath: indexPath)
            }
        }
    }
    
    func shrinkTransactions(indexPath: IndexPath) {
        for (index, transaction) in TransactionManager.transactions.enumerated() {
            if indexPath.row == index {
                transaction.expanded.toggle()
            } else {
                transaction.expanded = false
                if let cell = historyTableView.cellForRow(at: IndexPath(row: index, section: 0)) as? TransactionTableViewCell {
                    cell.contentView.backgroundColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
                }
            }
        }
    }
    
    func scrollCellIfNeeded(indexPath: IndexPath) {
        let rowRect = historyTableView.rectForRow(at: indexPath)
        let tableViewFrame = historyTableView.frame
        let transaction = TransactionManager.transactions[indexPath.row]
        let rowHeight: CGFloat = transaction.type == .receive ? recieveCellHeight : sendCellHeight
        if (rowRect.minY + rowHeight) > tableViewFrame.height {
            let gap = (rowRect.minY + rowHeight) - tableViewFrame.height
            let offset = CGPoint(x: historyTableView.contentOffset.x, y: historyTableView.contentOffset.y + gap)
            historyTableView.setContentOffset(offset, animated: true)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print(scrollView.contentOffset.y)
        if isExpanded {
            if scrollView.contentOffset.y < 0 {
                delegate?.setOffsetDown(scrollView.contentOffset.y)
                scrollView.contentOffset.y = 0
            }
        } else {
            if scrollView.contentOffset.y > 0 {
                delegate?.setOffsetUp(scrollView.contentOffset.y)
                scrollView.contentOffset.y = 0
            }
        }

    }
}

extension WalletsViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard tableView == historyTableView else { return }
        let lastElement = TransactionManager.transactions.count - 1
        for indexPath in indexPaths {
            if indexPath.row == lastElement, updatingEnable {
                currentPage += 1
                updateHistory(page: currentPage)
            }
        }
    }
}

extension WalletsViewController: TableBackgroundViewDelegate {
    func addCoin() {
        delegate?.showPinDialog(true)
    }
}

extension WalletsViewController: TransactionTableViewCellDelegate {
    func makeSimilarPayment(wallet: Wallet, amount: String, account: String?, isTopup: Bool, destinationTag: Int?, memo: String?) {
        if isTopup {
            if let topUpVC = UIStoryboard.get(flow: .topUp).instantiateInitialViewController() as? SelectCountryViewController {
                navigationController?.pushViewController(topUpVC, animated: true)
            }
        } else {
            if let vc = UIStoryboard.get(flow: .sendFlow).get(controller: .send) as? SendViewController {
                vc.wallet = wallet
                vc.amount = amount
                vc.address = account
                vc.destinationTag = destinationTag
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}

enum CurrentTable {
    case wallets
    case history
    case charts
}
