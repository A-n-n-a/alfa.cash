//
//  SetLanguageViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 15.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import RxLocalizer
import RxSwift
import RxCocoa


class SetLanguageViewController: BaseViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var headerLabel: HeaderLabel!
    @IBOutlet private weak var saveButton: BlueButton!
    
    
    private var appLanguage = LanguageManager.currentLanguage
    private var selectedLanguage: LanguageManager.AppLanguage = LanguageManager.currentLanguage {
        didSet {
            ApplicationManager.tempLanguage = selectedLanguage
            LanguageManager.switchLanguage(language: ApplicationManager.tempLanguage)
            if selectedLanguage != .english, selectedLanguage != .russian, selectedLanguage != LanguageManager.AppLanguage.thirdLanguage {
                LanguageManager.AppLanguage.optionsCases[2] = selectedLanguage
            } else {
                LanguageManager.AppLanguage.optionsCases[2] = LanguageManager.AppLanguage.thirdLanguage
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
        setUpBlueNavBar(title: "SELECT_YOUR_LANGUAGE", hideBackButton: false)//(title: , forLogin: true)
        
        if let tempLanguage = ApplicationManager.tempLanguage, tempLanguage != selectedLanguage {
            selectedLanguage = tempLanguage
        }
        tableView.reloadData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setup() {
        selectedLanguage = appLanguage
        
        tableView.register(cellClass: CheckboxTableViewCell.self)
    }
    
    @IBAction func saveButtonAction(_ sender: Any) {
       
        
        if let optionsContainerVC = UIStoryboard.get(flow: .options).instantiateInitialViewController() as? OptionsContainerViewController {
            navigationController?.pushViewController(optionsContainerVC, animated: true)
        }
    }
}

extension SetLanguageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return LanguageManager.AppLanguage.optionsCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(CheckboxTableViewCell.self), for: indexPath) as! CheckboxTableViewCell

        let language = LanguageManager.AppLanguage.optionsCases[indexPath.row]
        cell.language = language
        cell.selectedLanguage = selectedLanguage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let langCase = LanguageManager.AppLanguage.optionsCases[indexPath.row]
        if indexPath.row == 2,
        let vc = UIStoryboard.get(flow: .settings).get(controller: .languages) as? LanguagesViewController {
            vc.register = true
            vc.selectedLanguage = selectedLanguage
            navigationController?.pushViewController(vc, animated: true)
        } else if langCase != selectedLanguage {
            selectedLanguage = langCase
            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
}
