//
//  FiatManager.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 13.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

class FiatManager {

    static let allFiats: [Fiat] = [.usd, .rub, .gbp, .eur, .jpy, .chf, .cny, .sgd, .uah]
    static let popularFiats: [Fiat] = [.usd, .rub, .gbp, .eur]
    static let otherFiats: [Fiat] = [.jpy, .chf, .cny, .sgd, .uah]

    static var currentFiat: Fiat {
        return ApplicationManager.profile?.fiat ?? .usd
    }
    
    static var shouldUpdateBalance = false
}

enum Fiat: String {
    case eur, usd, rub, jpy, cny, chf, sgd, gbp, uah
    
    var sign: String {
        switch self {
        case .eur: return "€"
        case .usd: return "$"
        case .jpy: return "¥"
        case .rub: return "₽"
        case .chf: return "₣"
        case .cny: return "¥"
        case .sgd: return "$"
        case .gbp: return "£"
        case .uah: return "₴"
        }
    }
}
