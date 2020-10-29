//
//  Filter.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 03.05.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import TrustWalletCore

struct Filter: Equatable {
    let type: FiltersType
    let subType: FiltersSubtype
    var currency: String? = nil
    var selected: Bool
    
    static func ==(lhs: Filter, rhs: Filter) -> Bool {
        return  lhs.subType.name == rhs.subType.name && lhs.currency == rhs.currency
    }
}
