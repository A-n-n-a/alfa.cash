//
//  ReferralPayment.swift
//  alfa.cash
//
//  Created by Anna on 7/16/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class ReferralPayment: Decodable {
    
    var id: Int = 0
    var amount: Double = 0
    var amountUsd: Double = 0
    var timeCreated: Date = Date()
    var timePaid: Date = Date()
    var status: Int = 0
    var gate: String = ""
    var currency: String = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case amount
        case amountUsd = "amount_usd"
        case timeCreated = "time_created"
        case timePaid = "time_paid"
        case status
        case gate
        case currency
    }
    
    required convenience public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        amount = try container.decode(Double.self, forKey: .amount)
        amountUsd = try container.decode(Double.self, forKey: .amountUsd)
        let stringDateCreated = try container.decode(String.self, forKey: .timeCreated)
        if let date = stringDateCreated.toDateWith(format: Constants.DateFormats.referralFormat) {
            self.timeCreated = date
        }
        
        let stringDatePaid = try container.decode(String.self, forKey: .timePaid)
        if let date = stringDatePaid.toDateWith(format: Constants.DateFormats.referralFormat) {
            self.timePaid = date
        }
        
        status = try container.decode(Int.self, forKey: .status)
        gate = try container.decode(String.self, forKey: .gate)
        currency = try container.decode(String.self, forKey: .currency)
    }
}

