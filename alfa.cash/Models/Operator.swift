//
//  Operator.swift
//  alfa.cash
//
//  Created by Anna on 8/19/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import TrustWalletCore

class Operator: Decodable {
    var slug: String
    var name: String
    var logo: String
}

class LookupResponse: Decodable {
    var status: String
    var topupOperator: Operator
    var availableOperators: [Operator]
    var cryptocurrency: String
    var packages: [TopupPackage]?
    var rate: Double
    var rateCrypto: String
    var vat: VAT
    var customPrice: CustomPrice?
    
    var coin: CoinType? {
        return try? CoinType.getCoin(from: self.cryptocurrency)
    }
    
    enum CodingKeys: String, CodingKey {
        case status
        case cryptocurrency
        case topupOperator = "operator"
        case availableOperators = "available_operators"
        case packages
        case rate
        case rateCrypto = "rate_crypto"
        case vat
        case customPrice = "custom_price"
    }
}

class TopupPackage: Decodable {
    let amount: String
    let cryptoAmount: String
    let cryptoFee: String
    let currency: String
    let fee: String
    let hideMobile: Int
    
    enum CodingKeys: String, CodingKey {
        case amount
        case cryptoAmount = "crypto_amount"
        case cryptoFee = "crypto_fee"
        case currency
        case fee
        case hideMobile = "hide_mobile"
    }
}

struct VAT: Decodable {
    let info: String
    let percent: String
}

struct CustomPrice: Decodable {
    let currency: String
    let feePercent: String
    let max: Int
    let min: Int
    let minFee: Double
    
    enum CodingKeys: String, CodingKey {
        case currency
        case feePercent = "fee_percent"
        case max
        case min
        case minFee = "min_fee"
    }
}
