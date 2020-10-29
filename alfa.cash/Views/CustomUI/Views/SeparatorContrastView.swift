//
//  SeparatorContrastView.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 03.05.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

@IBDesignable class SeparatorContrastView: ACBorderedView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func setup() {
        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.textColor })
        
    }
}



