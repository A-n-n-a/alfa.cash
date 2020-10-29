//
//  Date.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 17.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

extension Date {
    public func toString(format: String) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: LanguageManager.currentLanguage.rawValue)
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
