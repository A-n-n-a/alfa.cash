//
//  UsernameTextField.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 20.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class UsernameTextField: ACTextField {
    
    override func setup() {
        self.theme.textColor = ThemeManager.shared.themed( { $0.textColor })
        self.theme.backgroundColor = ThemeManager.shared.themed( {$0.textfieldBackgroundColor} )
    }
}
