//
//  LegalViewController.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 17.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class LegalViewController: BaseViewController, ChildViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    let legals = ["PRIVACY_POLICY_TITLE", "TERMS_OF_SERVICE_TITLE"]
    var delegate: ContainerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpUI()
    }
    
    func setUpUI() {
        tableView.register(cellClass: LegalTableViewCell.self)
    }
    @IBAction func acceptAction(_ sender: Any) {
        delegate?.nextButtonAction(skip: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension LegalViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return legals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(LegalTableViewCell.self)) as! LegalTableViewCell
        cell.name = legals[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let vc = UIStoryboard.get(flow: .options).get(controller: .termsAndPrivacy) as? TermsAndPrivacyViewController {
            vc.legalType = indexPath.row == 0 ? .privacy : .terms
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
