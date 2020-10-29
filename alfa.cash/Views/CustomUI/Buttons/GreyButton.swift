//
//  GreyButton.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 14.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import UIKit

class GreyButton: ACButton {
    
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
        
        backgroundColor = .clear
        
        let titleColor = ThemeManager.shared.themed({ $0.headerTextColor as? UIColor})
        self.theme.titleColor(from: titleColor, for: .normal)
    }
}
