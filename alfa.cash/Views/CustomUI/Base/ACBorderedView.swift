//
//  ACBorderedView.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 24.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

@IBDesignable class ACBorderedView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            clipsToBounds = true
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
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

    }
}

