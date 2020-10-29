//
//  Profile.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 05.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

struct Profile: Codable {
    let id: Int
    var login: String
    let email: String
    let name: String
    private var defaultFiat: String
    private var lang: String
    var connectedToAlfacash: Bool?
    
    enum CodingKeys: String, CodingKey {
        case id
        case login
        case email
        case name
        case defaultFiat = "default_fiat"
        case lang = "language"
        case connectedToAlfacash = "alfacash_authenticated"
    }
    
    var language: LanguageManager.AppLanguage {
        get {
            return LanguageManager.AppLanguage(rawValue: lang) ?? .english
        }
        set {
            lang = newValue.rawValue
        }
    }
    
    var fiat: Fiat {
        get {
            return Fiat(rawValue: defaultFiat) ?? .usd
        }
        set {
            defaultFiat = newValue.rawValue
        }
    }
    
}

extension Profile {
    func differentFrom(_ profile: Profile) -> Bool {
        return (self.defaultFiat != profile.defaultFiat || self.lang != profile.lang)
    }
}
