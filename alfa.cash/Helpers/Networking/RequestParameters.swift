//
//  RequestParameters.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 22.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

protocol ParametersProtocol {
    typealias Parameters = [String: Any]
    
    var dictionaryValue: Parameters { get }
}

struct EmptyParameters: ParametersProtocol {
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = [:]
        
        return data
    }
}

struct UsernameExistsParameters: ParametersProtocol {
    var username: String
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = ["login": username]
        
        return data
    }
}

struct RegisterParameters: ParametersProtocol {
    var authData: AuthData
    
    var dictionaryValue: Parameters {
        var data:[String : Any] = ["address": authData.address,
                                   "signature": authData.signature]
        if let username = authData.username {
            data["login"] = username
        }
        
        if let referralId = UserDefaults.standard.value(forKey: Constants.Main.udReferralId) as? String {
            data["alfaRefId"] = referralId
        }
        
        return data
    }
}

struct AddressesParameters: ParametersProtocol {
    var address: WalletData
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = ["address" : address.address,
                                   "currency": address.currency]
        
        return data
    }
}

struct WalletIdParameters: ParametersProtocol {
    var walletId: Int
    var pin: Bool? = nil
    
    var dictionaryValue: Parameters {
        var data:[String : Any] = [:]
        if let pin = pin {
            data["pinned"] = pin
        }
        
        return data
    }
}

struct CreateTransactionParameters: ParametersProtocol, Codable {
    var walletId: Int
    var address: String
    var amount: String
    var advancedOptions: Memo?
    
    var dictionaryValue: Parameters {
        
        let data: [String : Any] = [:]
        return data
    }
    
    var postData: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(self)
            #if DEBUG
            print(String(data: data, encoding: .utf8)!)
            #endif
            return data
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        return nil
    }
    
    enum CodingKeys: String, CodingKey {
        case walletId
        case address = "to"
        case amount
        case advancedOptions
    }
}

struct Memo: Codable {
    var memo: String? = nil
    var destinationTag: Int? = nil
}

struct HistoryParameters: ParametersProtocol {
    var page: Int
    var currency: String?
    var pageSize: Int?
    var type: TransactionType?
    
    var dictionaryValue: Parameters {
        var filters: [String : Any] = [:]
        if let currency = currency {
            filters["currency"] = currency
            
        }
        if let type = type {
            filters["type"] = type.rawValue
        }
        var pageQuery = ["page" : page + 1]
        if let pageSize = pageSize {
            pageQuery["pageSize"] = pageSize
        }
        let data: [String : Any] = ["filters" : filters,
                                    "pageQuery" : pageQuery]
        
        return data
    }
}


struct WalletsBatchParameters: ParametersProtocol {
    let walletsData: [WalletData]
    
    var dictionaryValue: Parameters {
            
        var data: [String : Any] = [:]
        var wallets = [[String : Any]]()
        for wallet in walletsData {
            let walletData: [String : Any] = ["address" : wallet.address,
                                              "currency": wallet.currency]
            wallets.append(walletData)
        }
        
        data["wallets"] = wallets
        
        return data
    }
}

struct SubmitBitcoinParameters: ParametersProtocol {
    let txHex: String
    let headersInfo: TransactionHeadersInfo
    
    var dictionaryValue: Parameters {
            
        let data: [String : Any] = ["transaction" : txHex]
        return data
    }
    
    var headers: [String : String] {
        return headersInfo.requestHeaders
    }
}

struct SubmitEthereumParameters: ParametersProtocol {
    let input: TransactionEthereumInput
    let headersInfo: TransactionHeadersInfo
    
    var postData: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(input)
            return data
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        return nil
    }
    
    var dictionaryValue: Parameters {
            
        let data: [String : Any] = [:]
        return data
    }
    
    var headers: [String : String] {
        return headersInfo.requestHeaders
    }
}

struct SubmitStellarParameters: ParametersProtocol {
    let signature: String
    let headersInfo: TransactionHeadersInfo
    
    var dictionaryValue: Parameters {
            
        let data: [String : Any] = ["tx_blob" : signature]
        return data
    }
    
    var headers: [String : String] {
        return headersInfo.requestHeaders
    }
}

struct SubmitTronParameters: ParametersProtocol {
    let input: TransactionTronInput
    let headersInfo: TransactionHeadersInfo
    
    var dictionaryValue: Parameters {
        
        let data: [String : Any] = [:]
        return data
    }
    
    var postData: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(input)
            return data
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        return nil
    }
    
    var headers: [String : String] {
        return headersInfo.requestHeaders
    }
}

struct SubmitEosParameters: ParametersProtocol {
    let input: TransactionEosInput
    let headersInfo: TransactionHeadersInfo
    
    var dictionaryValue: Parameters {
        
        let data: [String : Any] = [:]
        return data
    }
    
    var postData: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(input)
            return data
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        return nil
    }
    
    var headers: [String : String] {
        return headersInfo.requestHeaders
    }
}

struct DerivationParameters: ParametersProtocol {
    var walletId: Int
    var address: String
    var derivation: Int
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = ["address" : address,
                                   "derivation" : derivation]
        
        return data
    }
}

struct ExchangePrepareParameters: ParametersProtocol {
    var walletFromId: Int
    var walletToId: Int
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = ["deposit_wallet_id" : walletFromId,
                                   "withdrawal_wallet_id" : walletToId]
        
        return data
    }
}

struct Options: Codable {
    let accountName: String
    let isEosActivation: Bool = true
}

struct ExchangeParameters: ParametersProtocol {
    
    let exchange: Exchange
    
    var postData: Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            let data = try encoder.encode(exchange)
            print(String(data: data, encoding: .utf8))
            return data
        } catch {
            #if DEBUG
            print(error)
            #endif
        }
        return nil
    }
    
    var dictionaryValue: Parameters {
            
        let data: [String : Any] = [:]
        return data
    }
    
//    var dictionaryValue: Parameters {
//        let data:[String : Any] = ["deposit_wallet_id" : walletFromId,
//                                   "withdrawal_wallet_id" : walletToId,
//                                   "deposit_amount" : amountFrom,
//                                   "withdrawal_amount" : amountTo,
//                                   "is_withdrawal_main" : isWindrawalMain]
//
//        return data
//    }
}

struct Exchange: Codable {
    var walletFromId: Int
    var walletToId: Int
    var amountFrom: String?
    var amountTo: String?
    var isWindrawalMain: Bool?
    var options: Options?
    
    enum CodingKeys: String, CodingKey {
        case walletFromId = "deposit_wallet_id"
        case walletToId = "withdrawal_wallet_id"
        case amountFrom = "deposit_amount"
        case amountTo = "withdrawal_amount"
        case isWindrawalMain = "is_withdrawal_main"
        case options
    }
}

struct RatesParameters: ParametersProtocol {
    var walletId: Int
    var period: ChartPeriod
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = [:]
        
        return data
    }
}

struct ProfileUpdateParameters: ParametersProtocol {
    var profile: Profile
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = ["id" : profile.id,
                                   "name" : profile.name,
                                   "email" : profile.email,
                                   "login" : profile.login,
                                   "language" : profile.language.rawValue,
                                   "default_fiat" : profile.fiat.rawValue]
        
        return data
    }
}

struct CheckEosAccountParameters: ParametersProtocol {
    let walletId: Int
    var account: String
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = ["accountName" : account]
        
        return data
    }
}

struct CreateEosAccountParameters: ParametersProtocol {
    let walletId: Int
    let account: String
    let pubKey: String
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = ["accountName" : account]
        
        return data
    }
}

struct PhoneParameters: ParametersProtocol {
    let phone: String
    var currency: String?
    var operat: String?
    
    var dictionaryValue: Parameters {
        var data:[String : Any] = ["phone" : phone]
        
        if let currency = currency {
            data["cryptocurrency"] = currency
        }
        
        if let operat = operat {
            data["operator"] = operat
        }
        
        return data
    }
}

struct EmailParameters: ParametersProtocol {
    let email: String
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = ["email" : email]
        
        return data
    }
}

struct TopupParameters: ParametersProtocol {
    let phone: String
    let currency: String
    let operat: String
    let amount: String
    let email: String
    
    var dictionaryValue: Parameters {
        let data:[String : Any] = ["phone" : phone,
                                   "cryptocurrency" : currency,
                                   "operator" : operat,
                                   "amount": amount,
                                   "create_order_confirm" : "0",
                                   "email" : email]
                                   
        return data
    }
}
