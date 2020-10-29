//
//  HowItWorksViewController.swift
//  alfa.cash
//
//  Created by Anna on 6/24/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class HowItWorksViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var levelsContainerHeight: NSLayoutConstraint!
    
    var levels = [Level]() {
        didSet {
            tableView.reloadData()
            let height = CGFloat(levels.count * 37)
            tableViewHeight.constant = height
            levelsContainerHeight.constant = height + 66
            view.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpHomeNavBar(title: "HOW_IT_WORKS")
        
        tableView.register(cellClass: LevelTableViewCell.self)
        
        getLevels()
    }
    
    func getLevels() {
        NetworkManager.getReferralLevels { [weak self] (levels, error) in
            if let error = error {
                self?.showError(error)
            }
            if let levels = levels {
                self?.levels = levels
            }
        }
    }
}

extension HowItWorksViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return levels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(LevelTableViewCell.self)) as! LevelTableViewCell
        cell.level = levels[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 37
    }
}
