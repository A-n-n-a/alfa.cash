//
//  BorderedThemedView.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 16.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class BorderedThemedView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.textfieldBackgroundColor })
        let borderColor = ThemeManager.currentTheme.associatedObject.textFieldBorderColor
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = ThemeManager.currentTheme == .day ? 2 : 0
    }
}

