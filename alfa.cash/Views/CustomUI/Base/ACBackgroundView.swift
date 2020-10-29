//
//  ACBackgroundView.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 16.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import RxTheme

@IBDesignable class ACBackgroundView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        subscribeToTheme()
    }
    
    func subscribeToTheme() {
        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.defaultBackgroundColor })
    }
}
