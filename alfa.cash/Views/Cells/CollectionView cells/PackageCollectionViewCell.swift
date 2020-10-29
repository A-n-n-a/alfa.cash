//
//  PackageCollectionViewCell.swift
//  alfa.cash
//
//  Created by Anna on 8/23/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class PackageCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var checkmarkIcon: UIImageView!
    @IBOutlet weak var valueLabel: TitleNoFontLabel!
    
    var package: TopupPackage? {
        didSet {
            setupCell()
        }
    }
    
    func setupCell(other: Bool = false) {
        layer.borderWidth = 1
        valueLabel.text = other ? "TOPUP_AMOUNT_OTHER_BUTTON".localized() : package?.amount
        
        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.cellBackgroundColor })
    }
    
    func setSelected(_ selected: Bool) {
        layer.borderColor = selected ? #colorLiteral(red: 0.03921568627, green: 0.5215686275, blue: 1, alpha: 1).cgColor : #colorLiteral(red: 0.8862745098, green: 0.8862745098, blue: 0.8862745098, alpha: 1).cgColor
        checkmarkIcon.isHidden = !selected
    }
}
