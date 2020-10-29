//
//  IncomeHistory.swift
//  alfa.cash
//
//  Created by Anna on 7/1/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class IncomeHistory: Decodable {
    
    var id: Int = 0
    var name: String = ""
    var amount: Double = 0
    var date: Date = Date()
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case amount
        case date
    }
    
    required convenience public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        amount = try container.decode(Double.self, forKey: .amount)
        let stringDate = try container.decode(String.self, forKey: .date)
        if let date = stringDate.toDateWith(format: Constants.DateFormats.referralFormat) {
            self.date = date
        }
    }
}
