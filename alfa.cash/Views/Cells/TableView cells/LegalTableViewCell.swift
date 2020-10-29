//
//  LegalTableViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 20.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class LegalTableViewCell: IndicatorTableViewCell {

    @IBOutlet weak var titleLabel: TitleLabel!
    
    var name: String! {
        didSet {
            titleLabel.setText(name)
        }
    }
}
