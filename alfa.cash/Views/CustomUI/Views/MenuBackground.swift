//
//  MenuBackground.swift
//  alfa.cash
//
//  Created by Anna on 7/24/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class MenuBackground: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.menuBackground })
    }
}


