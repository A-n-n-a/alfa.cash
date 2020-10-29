//
//  SettingsBackgroundView.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 20.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class SettingsBackgroundView: ACBackgroundView {
    
    override func subscribeToTheme() {
        self.theme.backgroundColor = ThemeManager.shared.themed( { $0.backgroundSettingsColor })
    }
}
