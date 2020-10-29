//
//  FaqViewController.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 06.05.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class FaqViewController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setUpHomeNavBar(title: "FAQ")
        
        tableView.register(cellClass: FaqTableViewCell.self)
    }
}

extension FaqViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId(FaqTableViewCell.self)) as! FaqTableViewCell
        cell.titleLabel.text = "question_\(indexPath.row)".localized()
        cell.subtitleLabel.text = "answer".localized()
        cell.setUpBackground()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
