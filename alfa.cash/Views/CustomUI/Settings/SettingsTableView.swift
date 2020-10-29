//
//  SettingsTableView.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 27.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import UIKit

class SettingsTableView: UITableView {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        setup()
    }

    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
//        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.defaultBackgroundColor })
    }
}
