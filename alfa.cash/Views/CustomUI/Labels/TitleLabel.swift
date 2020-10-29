//
//  TitleLabel.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 17.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import RxTheme

@IBDesignable class TitleLabel: ACLabel {
    
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
        self.theme.textColor = ThemeManager.shared.themed( { $0.textColor })
        self.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
}
