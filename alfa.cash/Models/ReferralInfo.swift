//
//  ReferralInfo.swift
//  alfa.cash
//
//  Created by Anna on 7/8/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

struct ReferralInfo: Decodable {
    let id: String 
    let link: String
    let balance: Double
    let earned: Double
    let level: Level
    let attractedUsers: Int
    let appReferralLink: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case link
        case balance
        case earned
        case level
        case attractedUsers = "attracted_users"
        case appReferralLink = "app_referral_link"
    }
}


struct Level: Decodable {
    let title: String
    let earning: Int?
    let percent: Int
    
    var isStandard: Bool {
        return title == "Standard"
    }
}
