//
//  MenuTableViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 15.06.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {

    @IBOutlet weak var itemName: UILabel!
    
    var menuItem: MenuItem! {
        didSet {
            itemName.text = menuItem.localizedKey.localized()
            selectionStyle = .none
        }
    }
}
