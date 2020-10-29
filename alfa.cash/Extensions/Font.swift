//
//  Font.swift
//  alfa.cash
//
//  Created by Anna on 7/14/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

extension UIFont {
    var medium: UIFont {
        return UIFont.systemFont(ofSize: self.pointSize, weight: .medium)
    }
    
    var semibold: UIFont {
        return UIFont.systemFont(ofSize: self.pointSize, weight: .semibold)
    }
    
    var bold: UIFont {
        return UIFont.systemFont(ofSize: self.pointSize, weight: .bold)
    }
    
    var regular: UIFont {
        return UIFont.systemFont(ofSize: self.pointSize, weight: .regular)
    }
}
