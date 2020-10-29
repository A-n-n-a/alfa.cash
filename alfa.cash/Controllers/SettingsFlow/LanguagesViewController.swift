//
//  LanguagesViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 20.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class LanguagesViewController: BaseViewController {
    
    @IBOutlet weak var tableView: SettingsTableView!
    @IBOutlet weak var searchTextField: SettingTextField!
    @IBOutlet weak var searchResultsTableView: SettingsTableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var selectedLanguage: LanguageManager.AppLanguage = LanguageManager.currentLanguage
    private var query = "" {
        didSet {
            if !query.isEmpty {
                searchResults = LanguageManager.AppLanguage.allCases.filter { (languageCase) -> Bool in
                    let nameForSearch = languageCase.name.localized().lowercased()
                    return nameForSearch.contains(query.lowercased())
                }
            } else {
                searchResults = []
            }
        }
    }
    
    var searchResults = [LanguageManager.AppLanguage]() {
        didSet {
            searchResultsTableView.alpha = searchResults.isEmpty ? 0 : 1
            searchResultsTableView.reloadData()
        }
    }
    
    var register = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBar(title: "SELECT_YOUR_LANGUAGE", rightButtonTitle: "SAVE".localized(), rightButtonSelector: #selector(saveLanguage))
        tableView.register(cellClass: CheckboxSettingsTableViewCell.self)
        searchResultsTableView.register(cellClass: CheckboxSettingsTableViewCell.self)
        
        searchTextField.setUpRightView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func saveLanguage() {
        if register {
            ApplicationManager.tempLanguage = selectedLanguage
            LanguageManager.switchLanguage()
            navigationController?.popViewController(animated: true)
        } else {
            activityIndicator.startAnimating()
            if var profileCopy = ApplicationManager.profile {
                profileCopy.language = selectedLanguage
                NetworkManager.updateProfile(profileCopy) { [weak self] (success, error) in
                    DispatchQueue.main.async {
                        if success {
                            self?.getProfile(completion: { (_) in
                                DispatchQueue.main.async {
                                    self?.activityIndicator.stopAnimating()
                                    ApplicationManager.needUpdateHomePage = true
                                    LanguageManager.switchLanguage()
                                    self?.navigationController?.popViewController(animated: true)
                                }
                            })
                        } else {
                            self?.activityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }
        
    }
}

extension LanguagesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == searchResultsTableView {
            return 1
        }
        return LanguageManager.sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchResultsTableView {
            return searchResults.count
        }
        let section = LanguageManager.sections[section]
        switch section {
        case .popular:
            return LanguageManager.popularSection.count
        case .all:
            return LanguageManager.allSection.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(CheckboxSettingsTableViewCell.self)) as! CheckboxSettingsTableViewCell
        
        let section = LanguageManager.sections[indexPath.section]
        
        var language: LanguageManager.AppLanguage
        if tableView == searchResultsTableView {
            language = searchResults[indexPath.row]
        } else {
            switch section {
            case .popular:
                language = LanguageManager.popularSection[indexPath.row]
            case .all:
                language = LanguageManager.allSection[indexPath.row]
            }
        }
        
        
        cell.language = language
        cell.selectedLanguage = selectedLanguage
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        let section = LanguageManager.sections[indexPath.section]
        
        var langCase: LanguageManager.AppLanguage
        switch section {
        case .popular:
            langCase = LanguageManager.popularSection[indexPath.row]
        case .all:
            langCase = LanguageManager.allSection[indexPath.row]
        }
        
        if tableView == searchResultsTableView {
            langCase = searchResults[indexPath.row]
        }
        
        if langCase != selectedLanguage {
            selectedLanguage = langCase
            tableView.reloadData()
            searchTextField.updatePlaceholderText()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        var text = ""
        let section = LanguageManager.sections[section]
        
        switch section {
        case .popular:
            text = "POPULAR"
        case .all:
            text = "ALL_LANGUAGES"
        }
        
        return text.headerThemedViewWithTitle()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == searchResultsTableView {
            return 0
        }
        return 45
    }
}

extension LanguagesViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            query = text.replacingCharacters(in: textRange, with: string)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}
