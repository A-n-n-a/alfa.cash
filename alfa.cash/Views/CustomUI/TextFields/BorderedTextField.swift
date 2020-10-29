//
//  BorderedTextField.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 17.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class BorderedTextField: ACTextField {
    
    override func setup() {
        self.theme.textColor = ThemeManager.shared.themed( { $0.textColor })
        self.theme.backgroundColor = ThemeManager.shared.themed( {$0.textfieldBackgroundColor} )
        layer.borderColor = ThemeManager.currentTheme.associatedObject.textFieldBorderColor.cgColor
        layer.borderWidth = 2
        
    }
}
