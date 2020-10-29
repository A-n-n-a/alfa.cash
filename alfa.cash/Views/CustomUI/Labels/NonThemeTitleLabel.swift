//
//  NonThemeTitleLabel.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 21.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

@IBDesignable class NonThemeTitleLabel: ACLabel {
    
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
        self.textColor = UIColor.kBlackColor
        self.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    }
}
