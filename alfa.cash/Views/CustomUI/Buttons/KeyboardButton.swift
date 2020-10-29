//
//  KeyboardButton.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 17.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class KeyboardButton: ACButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func setup() {
        super.setup()
        
        let titleColor = ThemeManager.shared.themed({ $0.textColor as? UIColor})
        self.theme.titleColor(from: titleColor, for: .normal)
        tintColor = ThemeManager.currentTheme.associatedObject.textColor
    }
}


