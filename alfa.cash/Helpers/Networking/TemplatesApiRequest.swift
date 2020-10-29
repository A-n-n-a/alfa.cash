//
//  TemplatesApiRequest.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 22.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

enum TemplatesAPIRequest: RestApiMethod {
    case userExists(UsernameExistsParameters)
    case register(RegisterParameters)
    case login(RegisterParameters)
    case getProfile(EmptyParameters)
    case updateProfile(ProfileUpdateParameters)
    case getWallets(EmptyParameters)
    case sendWallets(AddressesParameters)
    case getTransactions(HistoryParameters)
    case pin(WalletIdParameters)
    case createTransaction(CreateTransactionParameters)
    case submitBitcoinTransaction(SubmitBitcoinParameters)
    case submitEthereumTransaction(SubmitEthereumParameters)
    case submitStellarTransaction(SubmitStellarParameters)
    case submitTronTransaction(SubmitTronParameters)
    case submitEosTransaction(SubmitEosParameters)
    case walletsBatch(WalletsBatchParameters)
    case maxBalance(WalletIdParameters)
    case missingWallets(EmptyParameters)
    case receive(WalletIdParameters)
    case derivation(DerivationParameters)
    case exchangePrepare(ExchangeParameters)
    case exchange(ExchangeParameters)
    case rates(RatesParameters)
    case checkEosAccount(CheckEosAccountParameters)
    case notifications(EmptyParameters)
    case newNotifications(EmptyParameters)
    case referralAuth(EmptyParameters)
    case getReferralUser(EmptyParameters)
    case getReferralInfo(EmptyParameters)
    case getReferrals(EmptyParameters)
    case getReferralIncome(EmptyParameters)
    case getReferralPayments(EmptyParameters)
    case getReferralLevels(EmptyParameters)
    case payoutRequest(WalletIdParameters)
    case topupCurrencies(EmptyParameters)
    case topupLookup(PhoneParameters)
    case topupValidateEmail(EmailParameters)
    case createTopup(TopupParameters)
    
    var data: RestApiData {
        switch self {
        case .userExists(let parameters):
            return RestApiData(url: url+Endpoints.usernameExists, httpMethod: .post, parameters: parameters)
        case .register(let parameters):
            return RestApiData(url:  url+Endpoints.register, httpMethod: .post, parameters: parameters)
        case .login(let parameters):
            return RestApiData(url:  url+Endpoints.login, httpMethod: .post, parameters: parameters)
        case .getProfile(let parameters):
            return RestApiData(url: url+Endpoints.profile, httpMethod: .get, parameters: parameters)
        case .updateProfile(let parameters):
            return RestApiData(url: url+Endpoints.profile, httpMethod: .patch, parameters: parameters)
        case .getWallets(let parameters):
            return RestApiData(url: url+Endpoints.wallets, httpMethod: .get, parameters: parameters)
        case .sendWallets(let parameters):
            return RestApiData(url: url+Endpoints.wallets, httpMethod: .post, parameters: parameters)
        case .getTransactions(let parameters):
            return RestApiData(url: url+Endpoints.transactions, httpMethod: .post, parameters: parameters)
        case .pin(let parameters):
            return RestApiData(url: url+Endpoints.pin+String(parameters.walletId), httpMethod: .patch, parameters: parameters)
        case .createTransaction(let parameters):
            return RestApiData(url: url+Endpoints.createTransaction, httpMethod: .post, parameters: parameters, postData: parameters.postData)
        case .walletsBatch(let parameters):
           return RestApiData(url: url+Endpoints.walletsBatch, httpMethod: .post, parameters: parameters)
        case .submitBitcoinTransaction(let parameters):
            return RestApiData(url: url+Endpoints.submitTransaction, httpMethod: .post, headers: parameters.headers, parameters: parameters)
        case .submitEthereumTransaction(let parameters):
            return RestApiData(url: url+Endpoints.submitTransaction, httpMethod: .post, headers: parameters.headers, parameters: parameters, postData: parameters.postData)
        case .submitStellarTransaction(let parameters):
            return RestApiData(url: url+Endpoints.submitTransaction, httpMethod: .post, headers: parameters.headers, parameters: parameters)
        case .submitTronTransaction(let parameters):
            return RestApiData(url: url+Endpoints.submitTransaction, httpMethod: .post, headers: parameters.headers, parameters: parameters, postData: parameters.postData)
        case .submitEosTransaction(let parameters):
            return RestApiData(url: url+Endpoints.submitTransaction, httpMethod: .post, headers: parameters.headers, parameters: parameters, postData: parameters.postData)
        case .maxBalance(let parameters):
            let endpoint = String(format: Endpoints.maxBalance, parameters.walletId)
            return RestApiData(url: url+endpoint, httpMethod: .get, parameters: parameters)
        case .missingWallets(let parameters):
            return RestApiData(url: url+Endpoints.missingWallets, httpMethod: .get, parameters: parameters)
        case .receive(let parameters):
            let endpoint = String(format: Endpoints.receive, parameters.walletId)
            return RestApiData(url: url+endpoint, httpMethod: .get, parameters: parameters)
        case .derivation(let parameters):
            let endpoint = String(format: Endpoints.derivation, parameters.walletId)
            return RestApiData(url: url+endpoint, httpMethod: .post, parameters: parameters)
        case .exchangePrepare(let parameters):
            return RestApiData(url: url+Endpoints.exchangePrepare, httpMethod: .post, parameters: parameters, postData: parameters.postData)
        case .exchange(let parameters):
            return RestApiData(url: url+Endpoints.exchange, httpMethod: .post, parameters: parameters, postData: parameters.postData)
        case .rates(let parameters):
            let endpoint = String(format: Endpoints.rates, parameters.walletId, parameters.period.rawValue)
            return RestApiData(url: url+endpoint, httpMethod: .get, parameters: parameters)
        case .checkEosAccount(let parameters):
            let endpoint = String(format: Endpoints.eosAccountCheck, parameters.walletId)
            return RestApiData(url: url+endpoint, httpMethod: .post, parameters: parameters)
        case .notifications(let parameters):
            return RestApiData(url: url+Endpoints.notifications, httpMethod: .get, parameters: parameters)
        case .newNotifications(let parameters):
            return RestApiData(url: url+Endpoints.newNotifications, httpMethod: .get, parameters: parameters)
        case .referralAuth(let parameters):
            return RestApiData(url: url+Endpoints.referralAuth, httpMethod: .get, parameters: parameters)
        case .getReferralIncome(let parameters):
            return RestApiData(url: url+Endpoints.referralIncome, httpMethod: .get, parameters: parameters)
        case .getReferralInfo(let parameters):
            return RestApiData(url: url+Endpoints.referralInfo, httpMethod: .get, parameters: parameters)
        case .getReferralPayments(let parameters):
            return RestApiData(url: url+Endpoints.referralPayments, httpMethod: .get, parameters: parameters)
        case .getReferralUser(let parameters):
            return RestApiData(url: url+Endpoints.raferralUser, httpMethod: .get, parameters: parameters)
        case .getReferrals(let parameters):
            return RestApiData(url: url+Endpoints.referrals, httpMethod: .get, parameters: parameters)
        case .getReferralLevels(let parameters):
            return RestApiData(url: url+Endpoints.referralLevels, httpMethod: .get, parameters: parameters)
        case .payoutRequest(let parameters):
            return RestApiData(url: url+Endpoints.referralPayments, httpMethod: .post, parameters: parameters)
        case .topupCurrencies(let parameters):
            return RestApiData(url: url+Endpoints.topupCurrencies, httpMethod: .get, parameters: parameters)
        case .topupLookup(let parameters):
            return RestApiData(url: url+Endpoints.topupLookup, httpMethod: .post, parameters: parameters)
        case .topupValidateEmail(let parameters):
            return RestApiData(url: url+Endpoints.topupValidateEmail, httpMethod: .post, parameters: parameters)
        case .createTopup(let parameters):
            return RestApiData(url: url+Endpoints.topupCreate, httpMethod: .post, parameters: parameters)
        }
    }
}
