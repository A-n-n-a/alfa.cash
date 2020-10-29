//
//  TopupCurrencyCollectionViewCell.swift
//  alfa.cash
//
//  Created by Anna on 8/19/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class TopupCurrencyCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: CustomImageView!
    
    var currency: TopupCurrency! {
        didSet {
            setupCell()
        }
    }
    
    func setupCell() {
        imageView.image = UIImage(named: "\(currency.sign)_dark")
    }
}
