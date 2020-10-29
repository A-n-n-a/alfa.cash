//
//  PassсodeCircle.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 21.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class PasscodeCircle: UIView {

    private var color = "D8D8D8".hexColor()
    
    //=========================================================
    // MARK: - Initialization
    //=========================================================
   
    override init(frame: CGRect) {
       super.init(frame: frame)
       
       setup()
    }
   
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
       
       setup()
    }
   
    private func setup() {
        self.clipsToBounds = true
        self.layer.cornerRadius = 7.5
        setEmpty()
    }
    
    func setEmpty() {
        self.backgroundColor = .clear
        self.layer.borderWidth = 1
        self.layer.borderColor = color.cgColor
    }
    
    func setFilled() {
        self.backgroundColor = color
        self.layer.borderWidth = 0
    }
}
