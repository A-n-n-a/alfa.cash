//
//  BorderedFilledButton.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 17.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class BorderedFilledButton: ACButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func handleSelectection() {
        setSelected(active)
    }
    
    override func setup() {
        super.setup()
        
        self.titleLabel?.font =  UIFont.systemFont(ofSize: 14, weight: .medium)
        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.borderFilledButtonBackgroundColor })
        let titleColor = ThemeManager.shared.themed({ $0.borderFilledButtonTextColor as? UIColor})
        self.theme.titleColor(from: titleColor, for: .normal)
        layer.borderWidth = 2
        layer.borderColor = UIColor.kButtonColor.cgColor
    }
    
    func setSelected(_ selected: Bool) {
        let textColor = ThemeManager.currentTheme.associatedObject.borderFilledButtonTextColor
        if selected {
            backgroundColor = ThemeManager.currentTheme.associatedObject.borderFilledButtonBackgroundColor
            layer.borderColor = UIColor.kButtonColor.cgColor
            setTitleColor(textColor, for: .normal)
        } else {
            backgroundColor = ThemeManager.currentTheme.associatedObject.borderFilledButtonBackgroundColor.withAlphaComponent(0.45)
            layer.borderColor = UIColor.kButtonColor.withAlphaComponent(0.45).cgColor
            setTitleColor(textColor.withAlphaComponent(0.45), for: .normal)
        }
    }
}

