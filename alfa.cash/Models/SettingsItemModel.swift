//
//  SettingsItemModel.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 28.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class SettingsItemModel {
    let title: String
    var subtitle: String?
    var value: String?
    var valueBlack: Bool
    var image: UIImage?
    
    init(title: String, subtitle: String? = nil, value: String? = nil, valueBlack: Bool = true, image: UIImage? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.value = value
        self.valueBlack = valueBlack
        self.image = image
    }
}
