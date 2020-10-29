//
//  CountryCodeTableViewCell.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 05.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import FlagPhoneNumber

class CountryCodeTableViewCell: ACTableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var countryName: TitleNoFontLabel!
    @IBOutlet weak var codeLabel: SubtitleLabel!
    
    var country: FPNCountry! {
        didSet {
            countryName.text = country.name
            codeLabel.text = country.phoneCode
            icon.image = country.flag
        }
    }
}
