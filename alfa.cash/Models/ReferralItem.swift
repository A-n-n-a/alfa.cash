//
//  ReferralItem.swift
//  alfa.cash
//
//  Created by Anna on 7/2/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

struct ReferralItem: Decodable {
    
    let name: String
    let orders: Int
    let created: String
}
