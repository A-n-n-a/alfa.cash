//
//  SelectionLabel.swift
//  alfa.cash
//
//  Created by Anna on 7/14/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

@IBDesignable class SelectionLabel: ACLabel {
    
    @IBInspectable var active: Bool = false {
        didSet {
            setSelected(active)
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
    
    override func setup() {
        super.setup()
        
    }
    
    func setSelected(_ selected: Bool) {
        let weight: UIFont.Weight = selected ? .medium : .regular
        font =  UIFont.systemFont(ofSize: 14, weight: weight)
        textColor = selected ? .white : UIColor.white.withAlphaComponent(0.6)
    }
}
