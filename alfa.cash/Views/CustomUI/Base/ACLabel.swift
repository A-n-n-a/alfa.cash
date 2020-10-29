//
//  ACLabel.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 16.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import RxTheme

@IBDesignable class ACLabel: UILabel {
    
    @IBInspectable var localizedKey: String = "" {
        didSet {
            self.subscribeToLocalizedString(localizedKey)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
//        self.theme.textColor = ThemeManager.shared.themed( { $0.textColor })
    }
    
    func setText(_ text: String) {
        self.subscribeToLocalizedString(text)
    }
}
