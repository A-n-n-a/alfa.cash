//
//  CollectionView.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 14.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

extension UICollectionView {
    func register(cellClass: AnyClass) {
        let bundle = Bundle(for: cellClass)
        let nib = UINib(nibName: String(describing: cellClass), bundle: bundle)
        self.register(nib, forCellWithReuseIdentifier: String(describing: cellClass))
    }
}
