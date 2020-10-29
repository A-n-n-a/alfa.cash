//
//  HomePageBackgroundView.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 14.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

@IBDesignable class HomePageBackgroundView: UIView {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.homePageBackgroundColor })
    }
}
