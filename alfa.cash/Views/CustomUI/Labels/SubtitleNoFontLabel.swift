//
//  SubtitleNoFontLabel.swift
//  alfa.cash
//
//  Created by Anna on 8/24/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import RxTheme

@IBDesignable class SubtitleNoFontLabel: ACLabel {
    
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
        self.theme.textColor = ThemeManager.shared.themed( { $0.subtitleTextColor })
        self.numberOfLines = 0
    }
}

