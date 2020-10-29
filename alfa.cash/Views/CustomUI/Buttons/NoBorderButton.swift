//
//  NoBorderButton.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 17.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class NoBorderButton: ACButton {
    
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
        
        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.noBorderButtonBackgroundColor })
        let titleColor = ThemeManager.shared.themed({ $0.noBorderButtonTextColor as? UIColor})
        self.theme.titleColor(from: titleColor, for: .normal)
    }
}
