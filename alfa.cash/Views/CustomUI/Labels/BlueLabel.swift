//
//  BlueLabel.swift
//  alfa.cash
//
//  Created by Anna on 6/24/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import RxTheme

@IBDesignable class BlueLabel: ACLabel {
    
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
        self.theme.textColor = ThemeManager.shared.themed( { $0.blueLabelColor })
    }
}
