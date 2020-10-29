//
//  TableView.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 15.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

extension UITableView {
    func register(cellClass: AnyClass) {
        let bundle = Bundle(for: cellClass)
        let nib = UINib(nibName: String(describing: cellClass), bundle: bundle)
        self.register(nib, forCellReuseIdentifier: String(describing: cellClass))
    }
}
