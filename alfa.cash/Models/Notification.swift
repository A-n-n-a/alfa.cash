//
//  Notification.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 18.05.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class ACNotification: Decodable {
    var amount: String = ""
    var date: Date = Date()
    var id: Int = 0
    var type: NotificationType = .sent
    var userId: Int = 0
    var walletId: Int = 0
    
    enum CodingKeys: String, CodingKey {
           case amount
           case date
           case id
           case type
           case userId
           case walletId
       }
       
       required convenience public init(from decoder: Decoder) throws {
           self.init()
           let container = try decoder.container(keyedBy: CodingKeys.self)
           
           id = try container.decode(Int.self, forKey: .id)
           amount = try container.decode(String.self, forKey: .amount)
           userId = try container.decode(Int.self, forKey: .userId)
           let interval = try container.decode(Int.self, forKey: .date)
           date = Date(timeIntervalSince1970: TimeInterval(interval))
           walletId = try container.decode(Int.self, forKey: .walletId)
           let typeString = try container.decode(String.self, forKey: .type)
           type = NotificationType(rawValue: typeString) ?? .receive
       }
}


enum NotificationType: String {
    case receive = "transaction_in"
    case sent = "transaction_out"
}
