//
//  BorderedButton.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 17.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class BorderedButton: ACButton {
    
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
        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.borderButtonBackgroundColor })
        let titleColor = ThemeManager.shared.themed({ $0.borderButtonTextColor as? UIColor})
        self.theme.titleColor(from: titleColor, for: .normal)
        layer.borderWidth = 2
        layer.borderColor = UIColor.kButtonColor.cgColor
    }
    
    func setSelected(_ selected: Bool) {
        if selected {
            layer.borderColor = UIColor.kButtonColor.cgColor
            setTitleColor(UIColor.kButtonColor, for: .normal)
        } else {
            layer.borderColor = UIColor.kButtonColor.withAlphaComponent(0.45).cgColor
            setTitleColor(UIColor.kButtonColor.withAlphaComponent(0.45), for: .normal)
        }
    }
}
