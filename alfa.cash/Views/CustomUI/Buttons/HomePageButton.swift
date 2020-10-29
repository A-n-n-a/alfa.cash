//
//  HomePageButton.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 23.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class HomePageButton: ACButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func handleSelectection() {
        active ? setSelected() : setDeselected()
    }
    
    func setSelected() {
        backgroundColor = UIColor.kButtonColor
        let titleColor = ThemeManager.shared.themed({ $0.homePageButtonSelectedColor as? UIColor})
        self.theme.titleColor(from: titleColor, for: .normal)
    }
    
    func setDeselected() {
        backgroundColor = UIColor.clear
        let titleColor = ThemeManager.shared.themed({ $0.homePageButtonDeselectedColor as? UIColor})
        
        self.theme.titleColor(from: titleColor, for: .normal)
    }
}
