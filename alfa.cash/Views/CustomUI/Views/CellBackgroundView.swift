//
//  CellBackgroundView.swift
//  alfa.cash
//
//  Created by Anna on 7/23/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class CellBackgroundView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.cellBackgroundColor })
    }
}

