//
//  ResponseTypes.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 22.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

public enum Result<T> {
    case success(T)
    case failure(ACError)
}


struct BaseBoolResponse: Codable {
    var success: Bool?
    
    enum CodingKeys: String, CodingKey {
        case success
    }
}

struct UsernameExistsResponse: Codable {
    var exists: Bool
    
    enum CodingKeys: String, CodingKey {
        case exists = "data"
    }
}

struct ProfileResponse: Decodable {
    var profile: Profile
    
    enum CodingKeys: String, CodingKey {
        case profile = "data"
    }
}

struct WalletsResponse: Decodable {
    var wallets: [Wallet]
    
    enum CodingKeys: String, CodingKey {
        case wallets = "data"
    }
}

struct WalletResponse: Decodable {
    var wallet: Wallet
    
    enum CodingKeys: String, CodingKey {
        case wallet = "data"
    }
}

struct RegistrationResponse: Codable {
    var registration: Registration
    
    enum CodingKeys: String, CodingKey {
        case registration = "data"
    }
}

struct TransactionsResponse: Decodable {
    var transactions: [ACTransaction]
}

protocol CreateTransactionResponseProtocol {
    var prioritySupport: Bool { get set }
    var meta: [Meta] { get set }
}

struct Meta: Decodable {
    let title: String
    let value: String
    let fee: String
    let total: String
}

struct WalletGeneratedResponse: Decodable {
    var result: [GenerationResponse]
    
    enum CodingKeys: String, CodingKey {
        case result = "data"
    }
}

struct GenerationResponse: Decodable {
    let id: Int
    let userId: Int
    let currencyType: Int
    let amount: String
    let pinned: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case currencyType = "currency_type"
        case amount
        case pinned
    }
}

struct ReceiveResponse: Decodable {
    let result: WalletStatus
    
    enum CodingKeys: String, CodingKey {
        case result = "data"
    }
}

struct StringResponse: Codable {
    var data: String?
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}


// EXCHANGE

struct ExchangePrepareResponse: Decodable {
    var data: ExchangePrepare
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

struct ExchangePrepare: Decodable {
    let rates: Rates
    let limits: Limits
    let depositInfo: ExchangeInfo
    let withdrawalInfo: ExchangeInfo
}

struct Rates: Decodable {
    let gateDeposit: String
    let gateWithdrawal: String
    let pair: String
    let rate: String
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case gateDeposit = "gate_deposit"
        case gateWithdrawal = "gate_withdrawal"
        case pair
        case rate
        case error
    }
}


struct Limits: Decodable {
    let gateDeposit: String
    let gateWithdrawal: String
    let pair: String
    let fromMin: Double
    let fromMax: Double
    let toMin: Double
    let toMax: Double
    let error: String?
    
    enum CodingKeys: String, CodingKey {
        case gateDeposit = "gate_deposit"
        case gateWithdrawal = "gate_withdrawal"
        case pair
        case fromMin = "deposit_min"
        case fromMax = "deposit_max"
        case toMin = "withdrawal_min"
        case toMax = "withdrawal_max"
        case error
    }
}

struct ExchangeInfo: Decodable {
    let maxBalance: String
    let status: WalletStatus
}


struct WalletStatus: Decodable {
    let derivation: Int?
    let isActionRequired: Bool
    let isActive: Bool
}

struct ExchangeResponse: Decodable {
    var data: ExchangeResponseData
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
}

struct ExchangeResponseData: Decodable {
    let secretKey: String
    let deposit: Deposit
    let amountFrom: String
    let amountTo: String
    let orderId: String
    let eosActivationId: Int?
    
    enum CodingKeys: String, CodingKey {
        case secretKey = "secret_key"
        case deposit
        case amountFrom = "deposit_amount"
        case amountTo = "withdrawal_amount"
        case orderId = "order_id"
        case eosActivationId = "eos_activation_id"
    }
}

struct Deposit: Decodable {
    let address: String
    let account: String?
    let destinationTag: Int?
    let exchangeTag: String?
    
    enum CodingKeys: String, CodingKey {
        case address
        case account
        case destinationTag = "destination_tag"
        case exchangeTag = "exchange_tag"
    }
}

struct Rate: Decodable {
    let price: CGFloat
    let timestamp: Int
}

struct RatesResponse: Decodable {
    var rates: [Rate]
    
    enum CodingKeys: String, CodingKey {
        case rates = "data"
    }
}

struct NotificationsResponse: Decodable {
    var notifications: [ACNotification]
    
    enum CodingKeys: String, CodingKey {
        case notifications = "data"
    }
}

struct BoolResponse: Codable {
    var data: Bool
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

struct AuthResponse: Decodable {
    var data: RedirectUrl
    
    enum CodingKeys: String, CodingKey {
        case data
    }
}

struct RedirectUrl: Decodable {
    var redirectUrl: String
    
    enum CodingKeys: String, CodingKey {
        case redirectUrl = "redirect_url"
    }
    
}

struct ReferralUserResponse: Decodable {
    var user: ReferralUser
    
    enum CodingKeys: String, CodingKey {
        case user = "data"
    }
    
}

struct ReferralInfoResponse: Decodable {
    var info: ReferralInfo
    
    enum CodingKeys: String, CodingKey {
        case info = "data"
    }
    
}

struct ReferralsResponse: Decodable {
    var data: ReferralsDataResponse
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
}

struct ReferralsDataResponse: Decodable {
    var items: [ReferralItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "data"
    }
    
}

struct ReferralIncomeResponse: Decodable {
    var data: ReferralIncomeDataResponse
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
}
struct ReferralIncomeDataResponse: Decodable {
    var items: [IncomeHistory]
    
    enum CodingKeys: String, CodingKey {
        case items = "data"
    }
    
}

struct ReferralLevelsResponse: Decodable {
    var levels: [Level]
    
    enum CodingKeys: String, CodingKey {
        case levels = "data"
    }
    
}

struct ReferralPaymentsResponse: Decodable {
    var data: ReferralPaymentsDataResponse
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
}

struct ReferralPaymentsDataResponse: Decodable {
    var payments: [ReferralPayment]
    
    enum CodingKeys: String, CodingKey {
        case payments = "data"
    }
    
}

struct CurrenciesResponse: Decodable {
    var data: [TopupCurrency]
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
}

struct LookupDataResponse: Decodable {
    var data: LookupResponse
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
}

struct TopupDataResponse: Decodable {
    var data: TopupResponse
    
    enum CodingKeys: String, CodingKey {
        case data = "data"
    }
    
}

struct TopupResponse: Decodable {
    var status: String
    var orderId: String
    var payUrl: String //
    var deposit: Deposit
    var coinAmount: String
    var coinCurrency: String
    var qr: String //
    var expire: Int //
    var fee: Double
    var currency: String
    var receiveAmount: String
    var usdAmount: Double
    
    enum CodingKeys: String, CodingKey {
        case status
        case orderId = "order_id"
        case payUrl = "pay_url"
        case deposit
        case coinAmount = "coin_amount"
        case coinCurrency = "coin_currency"
        case qr
        case expire
        case fee
        case currency
        case receiveAmount = "receive_amount"
        case usdAmount = "usd_amount"
    }
    
}


