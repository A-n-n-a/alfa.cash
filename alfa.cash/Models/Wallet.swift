//
//  Wallet.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 05.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import TrustWalletCore

struct Wallet: Decodable {
    let id: Int
    let title: String
    let currency: String
    let amount: String
    let account: String
    let pinned: Bool
    let price: Double?
    let decimal: Int
    let available: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case currency
        case amount
        case account
        case pinned
        case price
        case decimal = "currency_decimal_places"
        case available = "available_amount"
    }
    
    var money: String {
        if let amountDouble = Double(amount), let price = self.price {
            let money = amountDouble * price
            return String(format: "%@ %.2f", FiatManager.currentFiat.sign, money)
        } else {
            return String(format: "%@ 0.00", FiatManager.currentFiat.sign)
        }
    }
    
    var coin: CoinType? {
        return try? CoinType.getCoin(from: self.currency)
    }
}
