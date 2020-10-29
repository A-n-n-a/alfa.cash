//
//  LightBlueButton.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 17.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class LightBlueButton: ACButton {
    
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
        
        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.cellBackgroundColor })
        let titleColor = ThemeManager.shared.themed({ $0.buttonBackgroundColor as? UIColor})
        self.theme.titleColor(from: titleColor, for: .normal)
    }
}
