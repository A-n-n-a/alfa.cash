//
//  TopupCurrency.swift
//  alfa.cash
//
//  Created by Anna on 8/19/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import TrustWalletCore

class TopupCurrency: Decodable {
    
    var name: String
    var sign: String
    var slug: String
    var image: String
    var localId: Int
    
    var coin: CoinType? {
        return try? CoinType.getCoin(from: self.sign)
    }
}
