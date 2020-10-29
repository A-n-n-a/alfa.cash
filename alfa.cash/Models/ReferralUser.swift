//
//  ReferralUser.swift
//  alfa.cash
//
//  Created by Anna on 7/8/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

struct ReferralUser: Decodable {
    let uid: Int
    let name: String
    let mail: String
    let created: String
    let access: String
    let login: String
    let timezone: String
    let language: String
}
