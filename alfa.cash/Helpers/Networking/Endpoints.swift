//
//  Endpoints.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 05.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

class Endpoints {
        
    #if DEV
    static let baseURL = "https://dev.alfacash.qbx44mvxr.work/api/v1/"
    #else
    static let baseURL = "https://dev.alfacash.qbx44mvxr.work/api/v1/"
    #endif
    

    static let usernameExists = "auth/login/check"
    static let register = "auth/register"
    static let login = "auth/login"
    static let profile = "profile"
    static let wallets = "wallets"
    static let pin = "wallets/"
    static let transactions = "transactions"
    static let createTransaction = "transactions/create"
    static let submitTransaction = "transactions/submit"
    static let walletsBatch = "wallets/batch"
    static let maxBalance = "wallets/%d/maxbalance"
    static let missingWallets = "wallets/missing"
    static let receive = "wallets/%d/receive"
    static let derivation = "wallets/%d/derivation"
    static let exchange = "exchange"
    static let exchangePrepare = "exchange/prepare"
    static let rates = "wallets/%d/rates/%@"
    static let eosAccountCheck = "wallets/%d/account/check"
    static let accountCreate = "wallets/%d/account"
    static let notifications = "notifications"
    static let newNotifications = "notifications/info"
    static let referralAuth = "referral/auth-link"
    static let raferralUser = "affiliate/user"
    static let referralInfo = "affiliate/info"
    static let referrals = "affiliate/referrals"
    static let referralIncome = "affiliate/income"
    static let referralPayments = "affiliate/payments"
    static let referralLevels = "affiliate/levels"
    static let topupCurrencies = "topup/currencies"
    static let topupLookup = "topup/lookup"
    static let topupValidateEmail = "topup/validate_email"
    static let topupCreate = "topup/create"
}
