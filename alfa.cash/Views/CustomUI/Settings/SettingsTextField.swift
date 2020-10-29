//
//  SettingsTextField.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 20.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class SettingTextField: ACTextField {
    
    override func setup() {
        super.setup()
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.kTextFieldBorderDay.cgColor
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        
        setUpRightView()
   }
}
