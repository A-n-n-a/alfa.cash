//
//  ACTextView.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 06.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import UIKit
import RxTheme
import RxLocalizer
import RxSwift
import RxCocoa
import UITextView_Placeholder


@IBDesignable class ACTextView: UITextView {
    
    @IBInspectable var placeholderKey: String = "" {
        didSet {
            updatePlaceholderText()
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            setupBorder()
        }
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {

    }
    
    func setupBorder() {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = 1
    }

    func updatePlaceholderText() {
        self.attributedPlaceholder = NSAttributedString(string: placeholderKey.localized(),
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.kPlaceholderColor])
    }
}
