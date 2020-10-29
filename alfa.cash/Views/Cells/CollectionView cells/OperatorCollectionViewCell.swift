//
//  OperatorCollectionViewCell.swift
//  alfa.cash
//
//  Created by Anna on 8/23/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class OperatorCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var logoContainer: UIView!
    @IBOutlet weak var logoImage: CustomImageView!
    @IBOutlet weak var checkmarkImage: UIImageView!
    @IBOutlet weak var operatorTitleLabel: SubtitleLabel!
    
    var topupOperator: Operator! {
        didSet {
            setupCell()
        }
    }
    
    func setupCell() {
        logoContainer.layer.borderWidth = 2
        logoImage.retrieveImgeFromLink(topupOperator.logo)
        operatorTitleLabel.text = topupOperator.name
    }
    
    func setSelected(_ selected: Bool) {
        logoContainer.layer.borderColor = selected ? #colorLiteral(red: 0.03921568627, green: 0.5215686275, blue: 1, alpha: 1).cgColor : #colorLiteral(red: 0.5921568627, green: 0.5921568627, blue: 0.5921568627, alpha: 0.26).cgColor
        checkmarkImage.isHidden = !selected
    }
}
