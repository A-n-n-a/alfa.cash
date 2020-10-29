//
//  NoBorderThemedButton.swift
//  alfa.cash
//
//  Created by Anna on 6/5/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

import UIKit

class NoBorderThemedButton: ACButton {
    
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
        
        self.backgroundColor = .clear
        let titleColor = ThemeManager.shared.themed({ $0.noBorderThemedButtonTextColor as? UIColor})
        self.theme.titleColor(from: titleColor, for: .normal)
    }
}
