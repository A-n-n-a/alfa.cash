//
//  MnemonicCollectionViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 24.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class MnemonicCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var wordLabel: UILabel!
    
    var word: String! {
        didSet {
            wordLabel.text = word
        }
    }
}
