//
//  HomePageViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 31.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import TrustWalletCore
import FirebaseCrashlytics

class HomePageViewController: BaseViewController {

    @IBOutlet weak var balanceContentView: UIView!
    @IBOutlet weak var walletsButton: HomePageButton!
    @IBOutlet weak var historyButton: HomePageButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var sendLabel: ACLabel!
    @IBOutlet weak var exchangeLabel: ACLabel!
    @IBOutlet weak var receiveLabel: ACLabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var filterIcon: UIImageView!
    @IBOutlet weak var sendIcon: UIImageView!
    @IBOutlet weak var exchangeIcon: UIImageView!
    @IBOutlet weak var receiveIcon: UIImageView!
    @IBOutlet weak var newNotificationsView: UIView!
    @IBOutlet weak var filtersBadgeView: UIView!
    @IBOutlet weak var filtersBadgeLabel: UILabel!
    
    
    private var walletsTopConstraint: NSLayoutConstraint?
    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var panDownGestureRecognizer: UIPanGestureRecognizer?
    var walletsVC: WalletsViewController?
    var walletsOffset: CGFloat = UIDevice.current.isFrameless() ? 60 : 40
    var baseHeight: CGFloat = 0
    var toolBarHeight: CGFloat = 63
    var balanceViewHeight: CGFloat = 250
    let gesturesViewHeight: CGFloat = 40
    var dialogView: DialogView!
    var filtersView: FiltersView!
    var menu: Menu!
    let menuWidth = UIScreen.main.bounds.width * 0.87
    let walletDialogHeight = UIScreen.main.bounds.height - 112
    let filtersViewHeignt: CGFloat = 570
    var homePageMode: HomePageMode = .wallets {
        didSet {
            updateFiltersBadge()
        }
    }
    var timer: Timer?
    var initialYposition: CGFloat?
    var scrollTimer: Timer?
    var lastConstraintConstant: CGFloat?
    var bottomReferralPopupConstraint: NSLayoutConstraint?
    let referralPopupView = ReferralPopup(frame: CGRect(x: 12, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width - 24, height: 370))
    let connectView = ConnectView(frame: CGRect(x: 12, y: UIScreen.main.bounds.height, width: UIScreen.main.bounds.width - 24, height: 284))
    var bottomConnectViewConstraint: NSLayoutConstraint?
    var hasNewNotifications = false {
        didSet {
            if hasNewNotifications != oldValue, hasNewNotifications {
                SoundManager.play(soundType: .receive)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        baseHeight = toolBarHeight + statusBarHeight() + bottomSafeHeight() + gesturesViewHeight
        
        getMissingWallets()
        getProfile()
        getreferralUrl() 
        
        showWallets()
        setUpUI()
        getNewNotifications()
        getReferralUser()
        initializeRecentOperationsGestures()
        
        referralPopupView.delegate = self
        connectView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        walletsVC?.backgroundView.setTableVewShortHeight(shortWalletsHeight())
        let height = longWalletsHeight()
        walletsVC?.setTableViewHeight(height)
        walletsVC?.chartsTableView.reloadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showHistory(notification:)), name: NSNotification.Name(rawValue: "ShowHistory"), object: nil)
        
        setUpToolBar()
        
        if FiatManager.shouldUpdateBalance {
            getWallets()
        }
        
        if ApplicationManager.needUpdateHomePage {
            setUpProfileUI()
            ApplicationManager.needUpdateHomePage = false
        }
        
        if ApplicationManager.needCheckNotifications {
            getNewNotifications()
            ApplicationManager.needCheckNotifications = false
        }
        
        setTimer()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.getProfile()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        walletsVC?.isExpanded = false
        timer?.invalidate()
        showWallets(false)
        switchToWallets(walletsButton.self as Any)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func showReferralPopup() {
        if !UserDefaults.standard.bool(forKey: Constants.Main.udReferralPopupWasShown), !(ApplicationManager.profile?.connectedToAlfacash ?? false) {
        self.showReferralPopupView()
            UserDefaults.standard.set(true, forKey: Constants.Main.udReferralPopupWasShown)
        }
    }
    
    func setUpToolBar() {
        view.bringSubviewToFront(toolBar)
        
        let toolBarColor = ThemeManager.currentTheme.associatedObject.homePageToolBarColor
        let view = UIView(frame: toolBar.frame)
        view.backgroundColor = toolBarColor
        let image = view.asImage()
        toolBar.setBackgroundImage(image, forToolbarPosition: .bottom, barMetrics: .default)
        
        let tintColor = ThemeManager.currentTheme.associatedObject.homePageToolBarTintColor
        let textColor = ThemeManager.currentTheme.associatedObject.homePageToolBarLabelTintColor
        
        sendLabel.textColor = textColor
        exchangeLabel.textColor = textColor
        receiveLabel.textColor = textColor
        sendLabel.setText("SEND")
        exchangeLabel.setText("EXCHANGE")
        receiveLabel.setText("RECEIVE")
        
        sendIcon.tintColor = tintColor
        exchangeIcon.tintColor = tintColor
        receiveIcon.tintColor = tintColor
    }
    
    func setUpUI() {

        let tap = UITapGestureRecognizer(target: self, action: #selector(closeWallets))
        balanceContentView.addGestureRecognizer(tap)
        
        let frame = view.frame
        dialogView = DialogView(frame: CGRect(x: 0, y: frame.maxY, width: frame.width, height: walletDialogHeight + 30))
        dialogView.navigationDelegate = self
        view.addSubview(dialogView)
        
        filtersView = FiltersView(frame: CGRect(x: 0, y: frame.maxY, width: frame.width, height: filtersViewHeignt + 30))
        filtersView.delegate = self
        view.addSubview(filtersView)
        
        menu = Menu(frame: CGRect(x: -menuWidth, y: 0, width: menuWidth, height: UIScreen.main.bounds.height))
        menu.delegate = self
        menu.alpha = 0
        view.addSubview(menu)
    }
    
    func setUpProfileUI() {
        LanguageManager.switchLanguage()
        if let username = ApplicationManager.profile?.login, !username.isEmpty {
            usernameLabel.text = "@\(username)"
        }
        menu.updateMenu()
    }
    
    func pingChanges() {
        getProfile(ping: true)
        getNewNotifications()
    }
    
    func setTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true, block: { (_) in
            self.pingChanges()
        })
    }
    
    func updateFiltersBadge() {
        if homePageMode == .wallets {
            filtersBadgeView.isHidden = true
        } else{
            filtersBadgeView.isHidden = TransactionManager.filters.isEmpty
            filtersBadgeLabel.text = "\(TransactionManager.filters.count)"
        }
    }
    
    func getNewNotifications() {
        NetworkManager.newNotifications {[weak self] (exists, error) in
            DispatchQueue.main.async {
                self?.hasNewNotifications = exists
                self?.newNotificationsView.isHidden = !exists
            }
        }
    }
    
    func getReferralUser() {
        NetworkManager.getReferralUser { (user, error) in
            DispatchQueue.main.async {
                if let email = user?.mail {
                    ApplicationManager.referralEmail = email
                }
            }
        }
    }
    
    func getMissingWallets() {
        NetworkManager.getMissingWallets { [weak self] (missingWallets, error) in
            DispatchQueue.main.async {
                if let missingWallets = missingWallets, !missingWallets.isEmpty {
                    let coins = missingWallets.compactMap { (currency) -> TrustWalletCore.CoinType? in
                        let coin = try? TrustWalletCore.CoinType.getCoin(from: currency)
                        return coin
                    }
                    self?.generateWallets(for: coins)
                } else {
                    self?.getWallets()
                }
            }
        }
    }
    
    func generateWallets(for coins: [CoinType]) {
        guard let walletsData = WalletManager.generatedAddresses(coins: coins) else {
            let error = ACError(message: "AN_UNEXPECTED_ERROR".localized())
            showError(error)
            return
        }
        
        NetworkManager.generateWallets(walletsData: walletsData) { [weak self] (wallets, error) in
            DispatchQueue.main.async {
                self?.getWallets()
            }
        }
    }
        
    func getWallets() {
        NetworkManager.getWallets { [weak self] (wallets, error) in
            DispatchQueue.main.async {
                
                if let wallets = wallets {
                    WalletManager.wallets = wallets
                    self?.walletsVC?.updateBackground()
                    self?.updateBalance()
                    self?.walletsVC?.walletsTableView.reloadData()
                }
                if let error = error {
                    self?.showError(error)
                }
            }
        }
    }
    
    func getProfile(ping: Bool = false) {
        activityIndicator.startAnimating()
        getProfile(ping: ping) { [weak self] (success) in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                if success {
                    self?.setUpProfileUI()
                    self?.showReferralPopup()
                }
            }
        }
    }
    
    func getreferralUrl() {
        NetworkManager.getReferralAuth { (link, _) in
            DispatchQueue.main.async {
                if let link = link, let url = URL(string: link) {
                    ApplicationManager.referralUrl = url
                }
            }
        }
    }

    func showWallets() {
        
        guard let walletsVC = UIStoryboard.get(flow: .home).get(controller: .wallets) as? WalletsViewController else { return }
        self.walletsVC = walletsVC
        walletsVC.delegate = self
        addChild(walletsVC)
        
        guard let content = walletsVC.view else {
            return
        }
        let bounds = view.bounds
        
        content.frame = CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: shortWalletsHeight())
        view.addSubview(content)

        walletsVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        walletsTopConstraint = content.topAnchor.constraint(equalTo: balanceContentView.bottomAnchor)
        
        NSLayoutConstraint.activate([content.leftAnchor.constraint(equalTo: view.leftAnchor),
                                     content.rightAnchor.constraint(equalTo: view.rightAnchor),
                                     content.heightAnchor.constraint(equalTo: view.heightAnchor),
                                     walletsTopConstraint ?? NSLayoutConstraint()
                                     ])
        
        walletsVC.didMove(toParent: self)
    }
    
    func statusBarHeight() -> CGFloat {
        if #available(iOS 13.0, *) {
            let sharedSceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            let window = sharedSceneDelegate?.window
            return window?.safeAreaInsets.top ?? 0
        } else {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? UIApplication.shared.statusBarFrame.size.height
        }
    }
    
    func bottomSafeHeight() -> CGFloat {
        if #available(iOS 13.0, *) {
            let sharedSceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            let window = sharedSceneDelegate?.window
            return window?.safeAreaInsets.bottom ?? 0
        } else {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.bottom ?? 0
        }
    }
    
    func shortWalletsHeight() -> CGFloat {
        let shortHeight = UIScreen.main.bounds.height - baseHeight - balanceViewHeight
        return shortHeight
    }
    
    func longWalletsHeight() -> CGFloat {
        let longHeight = UIScreen.main.bounds.height - baseHeight - walletsOffset
        return longHeight
    }
    
    private func prepareWalletsConstraints(open: Bool) {
        if open {
            walletsTopConstraint?.constant = -200
        } else {
            walletsTopConstraint?.constant = 0
        }
    }
    
    @objc func closeWallets() {
        showWallets(false)
    }
    
    override func handleDismiss() {
        showDialog(false)
        hideFilters()
        hideMenu()
        hideReferralPopupView()
        hideConnectView()
    }
    
    func showDialog(type: DialogType) {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        dialogView.dialogType = type
        window.addSubview(dialogView)
        blackView.frame = window.frame
        
        dialogView.updateTextFieldBorder()
        dialogView.resetCellsSelection()
        
        UIView.animate(withDuration: 0.2) {
            self.blackView.alpha = 1
            self.dialogView.transform = CGAffineTransform(translationX: 0, y: -self.walletDialogHeight)
        }
    }
    
    func hideDialog() {
        dialogView.textField.text = ""
        dialogView.textField.resignFirstResponder()
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.dialogView.transform = .identity
        }
    }
    
    func showFilters() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        window.addSubview(filtersView)
        blackView.frame = window.frame
        
        UIView.animate(withDuration: 0.2) {
            self.blackView.alpha = 1
            self.filtersView.transform = CGAffineTransform(translationX: 0, y: -self.filtersViewHeignt)
        }
    }
    
    func hideFilters() {
        if filtersView.selectedFilters != filtersView.selectedFiltersCopy {
            filtersView.selectedFiltersCopy = filtersView.selectedFilters
        }
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.filtersView.transform = .identity
        }
    }
    
    func showMenu() {
        guard let window = window else { return }
        menu.alpha = 1
        updateBlackView()
        window.addSubview(blackView)
        window.addSubview(menu)
        blackView.frame = window.frame
        
        UIView.animate(withDuration: 0.2) {
            self.blackView.alpha = 1
            self.menu.transform = CGAffineTransform(translationX: self.menuWidth, y: 0)
        }
    }
    
    func hideMenu() {
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.menu.transform = .identity
        }
    }
    
    @objc func showHistory(notification: Notification) {
        if let wallet = notification.userInfo?["wallet"] as? Wallet {
            filtersView.resetCoinFilter()
            for (index, filter) in filtersView.coinFilters.enumerated() {
                if filter.currency == wallet.currency {
                    filtersView.coinFilters[index].selected = true
                    TransactionManager.filters = [filtersView.coinFilters[index]]
                    updateFiltersBadge()
                }
            }
            filtersView.selectedFiltersCopy.append(Filter(type: .coin, subType: .coin, currency: wallet.currency, selected: true))
            filtersView.tableView.reloadData()
            getTransactions(currency: wallet.currency) {
                self.walletsVC?.updateBackground()
                self.switchToHistory(self.historyButton.self as Any)
            }
        }
    }
    
    func showConnectView() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        blackView.addSubview(connectView)
        connectView.translatesAutoresizingMaskIntoConstraints = false
        connectView.leadingAnchor.constraint(equalTo: blackView.leadingAnchor, constant: 12).isActive = true
        blackView.trailingAnchor.constraint(equalTo: connectView.trailingAnchor, constant: 12).isActive = true
        bottomConnectViewConstraint = blackView.bottomAnchor.constraint(equalTo: connectView.bottomAnchor, constant: 30)
        bottomConnectViewConstraint?.isActive = true
        connectView.heightAnchor.constraint(equalToConstant: 284).isActive = true
        blackView.frame = window.frame
        
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 1
            self.blackView.layoutIfNeeded()
        }
    }
    
    func hideConnectView() {
        bottomConnectViewConstraint?.constant = -400
        UIView.animate(withDuration: 0.3, animations: {
            self.blackView.alpha = 0
            self.blackView.layoutIfNeeded()
        }) { (_) in
            self.connectView.removeFromSuperview()
        }
    }

    @IBAction func showMenu(_ sender: Any) {
//        if let settingsVC = UIStoryboard.get(flow: .settings).instantiateInitialViewController() as? SettingsViewController {
//            navigationController?.pushViewController(settingsVC, animated: true)
//        }
        showMenu()
    }
    
    func updateBalance() {
        balanceLabel.text = String(format: "%@ %.2f", FiatManager.currentFiat.sign, WalletManager.balance)
    }
    
    func showReferralPopupView() {
        guard let window = window else { return }
        updateBlackView()
        window.addSubview(blackView)
        blackView.addSubview(referralPopupView)
        referralPopupView.translatesAutoresizingMaskIntoConstraints = false
        referralPopupView.leadingAnchor.constraint(equalTo: blackView.leadingAnchor, constant: 12).isActive = true
        blackView.trailingAnchor.constraint(equalTo: referralPopupView.trailingAnchor, constant: 12).isActive = true
        bottomReferralPopupConstraint = blackView.bottomAnchor.constraint(equalTo: referralPopupView.bottomAnchor, constant: 30)
        bottomReferralPopupConstraint?.isActive = true
        referralPopupView.heightAnchor.constraint(equalToConstant: 370).isActive = true
        blackView.frame = window.frame
        
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 1
            self.blackView.layoutIfNeeded()
        }
    }
    
    func hideReferralPopupView() {
        bottomReferralPopupConstraint?.constant = -400
        UIView.animate(withDuration: 0.3) {
            self.blackView.alpha = 0
            self.blackView.layoutIfNeeded()
        }
    }
    
    @IBAction func showNotifications(_ sender: Any) {
        guard !WalletManager.wallets.isEmpty else { return }
        if let vc = UIStoryboard.get(flow: .home).get(controller: .notificationsVC) as? NotificationsViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func showFilters(_ sender: Any) {
        if homePageMode == .wallets {
            walletsVC?.showCharts()
            walletsVC?.currentTable = .charts
            filterIcon.image = #imageLiteral(resourceName: "chartsSelected")
        } else {
            showFilters()
        }
    }
    
    @IBAction func switchToWallets(_ sender: Any) {
        homePageMode = .wallets
        
        historyButton.setDeselected()
        walletsButton.setSelected()
        
        walletsVC?.showWallets()
        walletsVC?.currentTable = .wallets
        filterIcon.image = #imageLiteral(resourceName: "charts")
    }
    
    @IBAction func switchToHistory(_ sender: Any) {
        homePageMode = .history
        
        walletsButton.setDeselected()
        historyButton.setSelected()
        
        walletsVC?.showHistory()
        walletsVC?.currentTable = .history
        if TransactionManager.transactions.isEmpty {
            walletsVC?.refreshHistory()
        }
        filterIcon.image = #imageLiteral(resourceName: "filter")
    }
    
    @IBAction func showSendScreen(_ sender: Any) {
        showDialog(type: .send)
    }
    
    @IBAction func showExchangeScreen(_ sender: Any) {
        if let vc = UIStoryboard.get(flow: .exchangeFlow).instantiateInitialViewController() as? ExchangeViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func showReceiveScreen(_ sender: Any) {
        showDialog(type: .receive)
    }
    
    private func initializeRecentOperationsGestures() {
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGestureRecognizer?.maximumNumberOfTouches = 1
        panGestureRecognizer?.delegate = self
        walletsVC?.view.addGestureRecognizer(panGestureRecognizer!)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        
        guard let walletsVC = walletsVC else { return }
        
        let velocity = gesture.velocity(in: view)
        let isVertical = abs(velocity.y) > abs(velocity.x)
        let isDown = isVertical && velocity.y > 0
        
        switch gesture.state {
        case .began:
            
            initialYposition = gesture.location(in: self.view).y
        case .changed:
            if let initialYposition = initialYposition {
                let difference = gesture.location(in: self.view).y - initialYposition
                if walletsVC.isExpanded {
                    let constant = -200 +  difference
                    if constant <= 0 && constant >= -200 {
                        walletsTopConstraint?.constant = constant
                        view.layoutIfNeeded()
                    }
                } else {
                    
                    if difference >= -200 && difference <= 0 {
                        walletsTopConstraint?.constant = difference
                        view.layoutIfNeeded()
                    }
                }
            }
        case .ended, .cancelled:
            if let initialYposition = initialYposition {
                let difference =  initialYposition - gesture.location(in: self.view).y
                
                if (isDown && walletsVC.isExpanded) || (!isDown && !walletsVC.isExpanded) {
                    walletsTopConstraint?.constant = difference < 100 ? 0 : -200
                    let isExpanded = difference >= 100
                    walletsVC.isExpanded = isExpanded
                }
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
        default:
            break
        }
    }
}

extension HomePageViewController: WalletsViewControllerDelegate {
    func showPinDialog(_ show: Bool) {
        showDialog(type: .pin)
    }
    
    func showWallets(_ open: Bool) {
        prepareWalletsConstraints(open: open)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func updateProfile() {
        getProfile()
    }
    
    func setOffsetUp(_ offset: CGFloat) {
        if scrollTimer?.isValid ?? false {
            scrollTimer?.invalidate()
        }
        if (walletsTopConstraint?.constant ?? 0) >= -200 /*&& (walletsTopConstraint?.constant ?? 0) <= 0 */{
            if (walletsTopConstraint?.constant ?? 0) > 0 {
                walletsTopConstraint?.constant = 0
            }
            walletsTopConstraint?.constant -= offset
            walletsTopConstraint?.constant = max(-200, walletsTopConstraint!.constant)
            if (walletsTopConstraint?.constant ?? 0) <= -200 {
                walletsVC?.isExpanded = true
            }

            lastConstraintConstant = walletsTopConstraint?.constant
            view.layoutIfNeeded()
            
            scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { (timer) in
                if self.lastConstraintConstant == self.walletsTopConstraint?.constant {
                    self.walletsTopConstraint?.constant = (self.walletsTopConstraint?.constant ?? 0) < -100 ? -200 : 0
                    let isExpanded = (self.walletsTopConstraint?.constant ?? 0) < -100
                    self.walletsVC?.isExpanded = isExpanded
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                    }
                    timer.invalidate()
                }
            })
        } else {
            walletsVC?.isExpanded = true
        }
    }
    
    func setOffsetDown(_ offset: CGFloat) {
        if scrollTimer?.isValid ?? false {
            scrollTimer?.invalidate()
        }
        
        if (walletsTopConstraint?.constant ?? 0) <= 0  && (walletsTopConstraint?.constant ?? 0) >= -200 {
            walletsTopConstraint?.constant -= offset
            if (walletsTopConstraint?.constant ?? 0) >= 0 {
                walletsVC?.isExpanded = false
            }
            
            lastConstraintConstant = walletsTopConstraint?.constant
            view.layoutIfNeeded()
            
            scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { (timer) in
                if self.lastConstraintConstant == self.walletsTopConstraint?.constant {
                    self.walletsTopConstraint?.constant = (self.walletsTopConstraint?.constant ?? 0) < -100 ? -200 : 0
                    let isExpanded = (self.walletsTopConstraint?.constant ?? 0) < -100
                    self.walletsVC?.isExpanded = isExpanded
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                    }
                    timer.invalidate()
                }
            })
        } else {
            walletsVC?.isExpanded = false
        }
    }
}

extension HomePageViewController: DialogViewNavigationDelegate {
    
    func goToReceive(wallet: Wallet) {
        if let vc = UIStoryboard.get(flow: .receiveFlow).get(controller: .receive) as? ReceiveViewController {
            vc.wallet = wallet
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func goToSend(wallet: Wallet) {
        if let vc = UIStoryboard.get(flow: .sendFlow).get(controller: .send) as? SendViewController {
            vc.wallet = wallet
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func showDialog(_ show: Bool) {
        if show {
            showDialog(type: .pin)
        } else {
            walletsVC?.updateBackground()
            hideDialog()
        }
    }
}

extension HomePageViewController: FiltersViewDelegate {
    func filtersSelected(_ filters: [Filter]) {
        TransactionManager.filters = filters
        updateFiltersBadge()
        walletsVC?.previousTransactionsCount = 0
        if filters.isEmpty {
            walletsVC?.updateHistory()
            hideFilters()
            return
        }
        walletsVC?.updateHistory()
        hideFilters()
    }
}

extension HomePageViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer == panGestureRecognizer && otherGestureRecognizer.view == walletsVC?.walletsTableView) || ( otherGestureRecognizer == panGestureRecognizer && gestureRecognizer.view == walletsVC?.walletsTableView) {
            return true
        } else {
            return false
        }
    }
}

extension HomePageViewController: MenuDelegate {
    func goToSend() {
        hideMenu()
        showDialog(type: .send)
    }
    
    func goToReceive() {
        hideMenu()
        showDialog(type: .receive)
    }
    
    func goToExchange() {
        hideMenu()
        if let vc = UIStoryboard.get(flow: .exchangeFlow).instantiateInitialViewController() as? ExchangeViewController {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func goToTopUp() {
        hideMenu()
        if let topUpVC = UIStoryboard.get(flow: .topUp).instantiateInitialViewController() as? SelectCountryViewController {
            navigationController?.pushViewController(topUpVC, animated: true)
        }
    }
    
    func goToReferral() {
        if ApplicationManager.profile?.connectedToAlfacash ?? false {
            hideMenu()
            if let referralVC = UIStoryboard.get(flow: .referral).instantiateInitialViewController() as? ReferralViewController {
                navigationController?.pushViewController(referralVC, animated: true)
            }
        } else {
            showConnectView()
        }
        
    }
    
    func goToSettings() {
        hideMenu()
        if let settingsVC = UIStoryboard.get(flow: .settings).instantiateInitialViewController() as? SettingsViewController {
            navigationController?.pushViewController(settingsVC, animated: true)
        }
    }
    
    func goToLanguages() {
        hideMenu()
        if let vc = UIStoryboard.get(flow: .settings).get(controller: .languages) as? LanguagesViewController {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func closeMenu() {
        hideMenu()
    }
}

extension HomePageViewController: ReferralPopupDelegate, ConnectViewDelegate {
    func getStarted() {
        hideReferralPopupView()
        showConnectView()
    }
    func connectToAlfa() {
        hideConnectView()
        hideMenu()
        connectToAlfacash()
    }
}

enum HomePageMode {
    case wallets
    case history
}
