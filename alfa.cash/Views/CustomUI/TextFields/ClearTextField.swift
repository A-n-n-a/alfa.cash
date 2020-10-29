//
//  ClearTextField.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 06.05.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class ClearTextField: ACTextField {
    
    override func setup() {
        self.theme.textColor = ThemeManager.shared.themed( { $0.textColor })
        backgroundColor = UIColor.clear
    }
}
