//
//  Menu.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 18.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

protocol MenuDelegate {
    func closeMenu()
    func goToSend()
    func goToReceive()
    func goToExchange()
    func goToTopUp()
    func goToReferral()
    func goToSettings()
    func goToLanguages()
}

class Menu: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var languageIcon: UIImageView!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var languageView: UIView!
    
    let menuItems: [MenuItem] = [.receive, .exchange, .send, .topUp, .referral, .settings]
    
    var lang: String {
        return LanguageManager.currentLanguage.localizedName
    }
    var icon: UIImage? {
        return LanguageManager.currentLanguage.icon
    }
    var delegate: MenuDelegate?
    
    var defaultResetColor: UIColor {
        return ThemeManager.currentTheme == .day ? UIColor.darkGray : UIColor.white.withAlphaComponent(0.5)
    }
   
    override init(frame: CGRect) {
       super.init(frame: frame)
       
       setup()
    }
   
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       
       setup()
    }
   
    private func setup() {
        let nib =  UINib(nibName: "Menu", bundle: Bundle(for: type(of: self)))
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.frame = CGRect(origin: CGPoint.zero, size: self.frame.size)
        self.addSubview(view)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(cellClass: MenuTableViewCell.self)
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipe.direction = .left
        self.addGestureRecognizer(swipe)
        
        languageLabel.text = lang
        languageIcon.image = icon
        topConstraint.constant = UIDevice.current.iPhoneSE() ? 40 : 70
    }
    
    @objc func swipeAction() {
        delegate?.closeMenu()
    }
    
    func updateMenu() {
        tableView.reloadData()
        languageLabel.text = lang
        languageIcon.image = icon
    }
    
    @IBAction func closeMenu(_ sender: Any) {
        delegate?.closeMenu()
    }
    
    @IBAction func selectLanguage(_ sender: Any) {
        delegate?.goToLanguages()
    }
}

extension Menu: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: MenuTableViewCell.self)) as! MenuTableViewCell
        cell.menuItem = menuItems[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let menuItem = menuItems[indexPath.row]
        switch menuItem {
        case .receive:
            delegate?.goToReceive()
        case .exchange:
            delegate?.goToExchange()
        case .send:
            delegate?.goToSend()
        case .topUp:
            delegate?.goToTopUp()
        case .referral:
            delegate?.goToReferral()
        case .settings:
            delegate?.goToSettings()
        }
    }
}

enum MenuItem {
    case receive
    case exchange
    case send
    case topUp
    case referral
    case settings

    
    var localizedKey: String {
        switch self {
        case .receive:
            return "RECEIVE"
        case .exchange:
            return "EXCHANGE"
        case .referral:
            return "SETTINGS_REFER_EARN"
        case .send:
            return "SEND"
        case .settings:
            return "SETTINGS"
        case .topUp:
            return "TOP_UP"
        }
    }
}
