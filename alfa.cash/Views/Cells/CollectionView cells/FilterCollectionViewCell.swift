//
//  FilterCollectionViewCell.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 02.05.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var filterButton: BorderedButton!
    
    var filter: Filter! {
        didSet {
            if let title = filter.currency?.uppercased() {
                filterButton.setLocalizedTitle(title)
            } else {
                filterButton.setTitle(filter.subType.localizedKey)
            }
            
            filterButton.setSelected(filter.selected)
        }
    }
}
