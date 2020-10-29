//
//  ACTextField.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 20.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import RxTheme
import RxLocalizer
import RxSwift
import RxCocoa


@IBDesignable class ACTextField: UITextField {
    
    @IBInspectable var textKey: String = "" {
        didSet {
            self.subscribeToLocalizedString(textKey)
        }
    }
    
    @IBInspectable var placeholderKey: String = "" {
        didSet {
            updatePlaceholderText()
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
    
    func setText(_ text: String) {
        self.subscribeToLocalizedString(text)
    }

    func updatePlaceholderText() {
        self.attributedPlaceholder = NSAttributedString(string: placeholderKey.localized(),
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.kPlaceholderColor])
    }
    
    func setUpRightView() {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "searchIcn"))
        imageView.frame = CGRect(x: 8, y: 8, width: 16, height: 16)
        rightView = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 32))
        rightView?.addSubview(imageView)
        rightViewMode = .always
    }
}
