//
//  Registration.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 06.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

struct Registration: Codable {
    let auth: Auth
    let user: Profile
}

struct Auth: Codable {
    var token: String
    var createdAt: Int
    
    enum CodingKeys: String, CodingKey {
        case token
        case createdAt = "created_at"
    }
}
