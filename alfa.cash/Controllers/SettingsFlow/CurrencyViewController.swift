//
//  CurrencyViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 13.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class CurrencyViewController: BaseViewController {
    
    @IBOutlet weak var tableView: SettingsTableView!
    @IBOutlet weak var searchTextField: SettingTextField!
    @IBOutlet weak var searchResultsTableView: SettingsTableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    private var selectedFiat: Fiat = FiatManager.currentFiat
    private var query = "" {
        didSet {
            if !query.isEmpty {
                searchResults = FiatManager.allFiats.filter { (fiatCase) -> Bool in
                    let nameForSearch = fiatCase.rawValue.lowercased()
                    return nameForSearch.contains(query.lowercased())
                }
            } else {
                searchResults = []
            }
        }
    }
    
    var searchResults = [Fiat]() {
        didSet {
            searchResultsTableView.alpha = searchResults.isEmpty ? 0 : 1
            searchResultsTableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpNavBar(title: "SELECT_CURRENCY", rightButtonTitle: "SAVE".localized(), rightButtonSelector: #selector(saveLanguage))
        tableView.register(cellClass: CheckboxSettingsTableViewCell.self)
        searchResultsTableView.register(cellClass: CheckboxSettingsTableViewCell.self)
        
        searchTextField.setUpRightView()
    }
    
    @objc func saveLanguage() {
        activityIndicator.startAnimating()
        if var profileCopy = ApplicationManager.profile {
            profileCopy.fiat = selectedFiat
            NetworkManager.updateProfile(profileCopy) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    if success {
                        self?.getProfile(completion: { (_) in
                            DispatchQueue.main.async {
                                self?.activityIndicator.stopAnimating()
                                FiatManager.shouldUpdateBalance = true
                                ApplicationManager.ratesNeedUpdate = true
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

extension CurrencyViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == searchResultsTableView {
            return searchResults.count
        }
        if section == 0 {
            return FiatManager.popularFiats.count
        } else {
            return FiatManager.otherFiats.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(CheckboxSettingsTableViewCell.self)) as! CheckboxSettingsTableViewCell
        
        var fiat: Fiat
        if tableView == searchResultsTableView {
            fiat = searchResults[indexPath.row]
        } else {
            if indexPath.section == 0 {
                fiat = FiatManager.popularFiats[indexPath.row]
            } else {
                fiat = FiatManager.otherFiats[indexPath.row]
            }
        }
        
        cell.fiat = fiat
        cell.selectedFiat = selectedFiat
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        
        
        var fiatCase: Fiat
        
        if tableView == searchResultsTableView {
            fiatCase = searchResults[indexPath.row]
        } else if indexPath.section == 0 {
            fiatCase = FiatManager.popularFiats[indexPath.row]
        } else {
            fiatCase = FiatManager.otherFiats[indexPath.row]
        }
        
        if fiatCase != selectedFiat {
            selectedFiat = fiatCase
            tableView.reloadData()
            searchTextField.updatePlaceholderText()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == searchResultsTableView {
            return nil
        } else if section == 0 {
            return "POPULAR".headerThemedViewWithTitle()
        } else {
            return "ALL_CURRENCIES".headerThemedViewWithTitle()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == searchResultsTableView {
            return 0
        }
        return 45
    }
}

extension CurrencyViewController: UITextFieldDelegate {
    
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
