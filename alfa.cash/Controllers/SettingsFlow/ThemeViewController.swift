//
//  ThemeViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 13.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class ThemeViewController: BaseViewController {
    
    @IBOutlet weak var tableView: SettingsTableView!
    @IBOutlet weak var icon: UIImageView!
    
    private var selectedTheme: ThemeManager.ThemeType = ThemeManager.currentTheme {
        didSet {
            updateThemeIcon()
            ThemeManager.shared.saveTheme(selectedTheme)
            ThemeManager.shared.themeService.switch(selectedTheme)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavbar()
        tableView.register(cellClass: CheckboxSettingsTableViewCell.self)
        updateThemeIcon()
    }
    
    func setupNavbar() {
        setUpNavBar(title: "APPEARANCE")
    }
    
    func updateThemeIcon() {
        switch selectedTheme {
        case .day:
            icon.image = #imageLiteral(resourceName: "day mode")
        case .night:
            icon.image = #imageLiteral(resourceName: "night mode asset")
        case .trueNight:
            icon.image = #imageLiteral(resourceName: "dark mode asset")
        }
    }
}

extension ThemeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return ThemeManager.availableThemes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(CheckboxSettingsTableViewCell.self)) as! CheckboxSettingsTableViewCell
        
        let theme = ThemeManager.availableThemes[indexPath.row]
        cell.theme = theme
        cell.selectedTheme = selectedTheme
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let themeCase = ThemeManager.availableThemes[indexPath.row]
        if themeCase != selectedTheme {
            selectedTheme = themeCase
            tableView.reloadData()
        }
        
        setupNavbar()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        return "CHOOSE_YOUR_APP_SKIN".headerThemedViewWithTitle()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
}
