//
//  HeaderButton.swift
//  alfa.cash
//
//  Created by Anna on 6/26/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class HeaderButton: ACButton {
    
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
    }
    
    func setSelected(_ selected: Bool) {
        let weight: UIFont.Weight = selected ? .medium : .regular
        self.titleLabel?.font =  UIFont.systemFont(ofSize: 14, weight: weight)
        let textColor: UIColor = selected ? .white : UIColor.white.withAlphaComponent(0.58)
        setTitleColor(textColor, for: .normal)
    }
}

