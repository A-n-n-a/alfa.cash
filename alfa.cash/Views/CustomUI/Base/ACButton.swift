//
//  ACButton.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 16.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

@IBDesignable class ACButton: UIButton {
    
    @IBInspectable var localizedKey: String = "" {
        didSet {
            self.subscribeToLocalizedString(localizedKey)
        }
    }
    
    @IBInspectable var shouldRoundCorner: Bool = true {
        didSet {
            clipsToBounds = shouldRoundCorner
            if !shouldRoundCorner {
                layer.cornerRadius = 0
            }
        }
    }
    
    @IBInspectable var active: Bool = false {
        didSet {
            handleSelectection()
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
        layer.cornerRadius = 6
        clipsToBounds = true
    }
    
    func setTitle(_ text: String) {
        self.subscribeToLocalizedString(text)
    }
    
    func setLocalizedTitle(_ text: String) {
        self.setTitle(text, for: .normal)
    }
    
    func handleSelectection() {
        
    }
}
