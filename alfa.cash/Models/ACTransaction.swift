//
//  Transaction.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 17.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

class ACTransaction: Decodable {
    var id: Int = 0
    var hash: String = ""
    var type: TransactionType = .receive
    var currencyType: String = ""
    var userId: Int = 0
    var blockId: String = ""
    var balanceChange: String = ""
    var fee: String = ""
    var time: Date = Date()
    var walletId: Int = 0
    var tags: [String]?
    var expanded = false
    var status: Status = .finished
    var toAddress: String?
    var login: String?
    var additional: Additional?
    
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case hash
        case type
        case currencyType
        case userId
        case blockId
        case balanceChange
        case fee
        case time
        case walletId
        case tags
        case status
        case toAddress
        case login
        case additional
    }
    
    required convenience public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        hash = try container.decode(String.self, forKey: .hash)
        currencyType = try container.decode(String.self, forKey: .currencyType)
        userId = try container.decode(Int.self, forKey: .userId)
        blockId = try container.decode(String.self, forKey: .blockId)
        balanceChange = try container.decode(String.self, forKey: .balanceChange)
        fee = try container.decode(String.self, forKey: .fee)
        let interval = try container.decode(Int.self, forKey: .time)
        time = Date(timeIntervalSince1970: TimeInterval(interval))
        walletId = try container.decode(Int.self, forKey: .walletId)
        tags = try? container.decode([String].self, forKey: .tags)
        let typeString = try container.decode(String.self, forKey: .type)
        type = TransactionType(rawValue: typeString) ?? .receive
        let statusString = try container.decode(String.self, forKey: .status)
        status = Status(rawValue: statusString) ?? .finished
        toAddress = try? container.decode(String.self, forKey: .toAddress)
        login = try? container.decode(String.self, forKey: .login)
        additional = try? container.decode(Additional.self, forKey: .additional)
        guard let tags = tags else { return }
        for tag in tags {
            if tag == "ace" {
                type = .exchange
            }
            if tag == "act" {
                type = .topup
            }
        }
    }
}


enum TransactionType: String, CaseIterable {
    case receive = "in"
    case send = "out"
    case topup
    case exchange
    
    var label: String {
        switch self {
        case .receive:
            return "RECEIVED".localized()
        case .send, .exchange:
            return "SENT".localized()
        case .topup:
            return "TOPUP_BUTTON".localized()
        }
    }
}

enum Status: String {
    case finished = "finished"
    case pending = "pending"
}

struct Additional: Decodable {
    let action: String
    let orderId: String
    let topupPhone: String
    let paymentTag: String
}
