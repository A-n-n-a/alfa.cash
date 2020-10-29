//
//  LegalSettingsViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 29.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class LegalSettingsViewController: BaseViewController {

    @IBOutlet weak var tableView: SettingsTableView!
    
    let legals = ["PRIVACY_POLICY_TITLE", "TERMS_OF_SERVICE_TITLE"]
    var viewModel = SettingsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(cellClass: SettingsBaseTableViewCell.self)
    }

    override func viewWillAppear(_ animated: Bool) {
        setUpNavBar(title: "LEGAL")
    }
}

extension LegalSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return legals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let settingsCell = tableView.dequeueReusableCell(withIdentifier: cellId(SettingsBaseTableViewCell.self)) as! SettingsBaseTableViewCell
        let model = viewModel.settingsModel(title: legals[indexPath.row])
        
        settingsCell.model = model
        
        return settingsCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return "LEGAL".headerThemedViewWithTitle()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let vc = UIStoryboard.get(flow: .options).get(controller: .termsAndPrivacy) as? TermsAndPrivacyViewController {
            vc.legalType = indexPath.row == 0 ? .privacy : .terms
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
