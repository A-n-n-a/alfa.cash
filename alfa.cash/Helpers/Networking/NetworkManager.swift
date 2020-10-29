//
//  NetworkManager.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 22.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import TrustWalletCore

class NetworkManager {
    

    typealias Completion = ((_ success: Bool, _ error: ACError?) -> Void)?
    typealias StringCompletion = ((_ string: String?, _ error: ACError?) -> Void)?
    typealias StringArrayCompletion = ((_ string: [String]?, _ error: ACError?) -> Void)?
    typealias UsernameExistsCompletion = ((_ success: Bool?, _ error: ACError?) -> Void)?
    typealias RegistrationCompletion = ((_ success: Registration?, _ error: ACError?) -> Void)?
    typealias ProfileCompletion = ((_ profile: Profile?, _ error: ACError?) -> Void)?
    typealias WalletsCompletion = ((_ wallets: [Wallet]?, _ error: ACError?) -> Void)?
    typealias WalletCompletion = ((_ wallets: Wallet?, _ error: ACError?) -> Void)?
    typealias TransactionsCompletion = ((_ wallets: [ACTransaction]?, _ error: ACError?) -> Void)?
    typealias CreateBitcoinTransactionsCompletion = ((_ response: CreateBitcoinTransactionResponse?, _ error: ACError?) -> Void)?
    typealias CreateEthereumTransactionsCompletion = ((_ response: CreateEthereumTransactionResponse?, _ error: ACError?) -> Void)?
    typealias CreateStellarTransactionsCompletion = ((_ response: CreateStellarTransactionResponse?, _ error: ACError?) -> Void)?
    typealias CreateTronTransactionsCompletion = ((_ response: CreateTronTransactionResponse?, _ error: ACError?) -> Void)?
    typealias CreateEosTransactionsCompletion = ((_ response: CreateEosTransactionResponse?, _ error: ACError?) -> Void)?
    typealias ReceiveCompletion = ((_ response: WalletStatus?, _ error: ACError?) -> Void)?
    typealias ExchangePrepareCompletion = ((_ response: ExchangePrepare?, _ error: ACError?) -> Void)?
    typealias ExchangeCompletion = ((_ response: ExchangeResponseData?, _ error: ACError?) -> Void)?
    typealias RatesCompletion = ((_ response: [Rate]?, _ error: ACError?) -> Void)?
    typealias NotificationsCompletion = ((_ response: [ACNotification]?, _ error: ACError?) -> Void)?
    typealias ReferralUserCompletion = ((_ response: ReferralUser?, _ error: ACError?) -> Void)?
    typealias ReferralInfoCompletion = ((_ response: ReferralInfo?, _ error: ACError?) -> Void)?
    typealias ReferralsCompletion = ((_ response: [ReferralItem]?, _ error: ACError?) -> Void)?
    typealias ReferralIncomeCompletion = ((_ response: [IncomeHistory]?, _ error: ACError?) -> Void)?
    typealias ReferralPaymentCompletion = ((_ response: [ReferralPayment]?, _ error: ACError?) -> Void)?
    typealias ReferralLevelsCompletion = ((_ response: [Level]?, _ error: ACError?) -> Void)?
    typealias TopupCurrenciesCompletion = ((_ response: [TopupCurrency]?, _ error: ACError?) -> Void)?
    typealias LookupCompletion = ((_ response: LookupResponse?, _ error: ACError?) -> Void)?
    typealias TopupCompletion = ((_ response: TopupResponse?, _ error: ACError?) -> Void)?
    
    static func isUsernameExists(_ username: String, completion: UsernameExistsCompletion) {
        
        let param = UsernameExistsParameters(username: username)
        let request = TemplatesAPIRequest.userExists(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<UsernameExistsResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.exists, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func register(authData: AuthData, completion: RegistrationCompletion) {
        
        let param = RegisterParameters(authData: authData)
        let request = TemplatesAPIRequest.register(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<RegistrationResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.registration, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func login(authData: AuthData, completion: RegistrationCompletion) {
        
        let param = RegisterParameters(authData: authData)
        let request = TemplatesAPIRequest.login(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<RegistrationResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.registration, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func getProfile(completion: ProfileCompletion) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.getProfile(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<ProfileResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.profile, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func updateProfile(_ profile: Profile, completion: Completion) {
        
        let param = ProfileUpdateParameters(profile: profile)
        let request = TemplatesAPIRequest.updateProfile(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<BaseBoolResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success:
                    completion?(true, nil)
                case .failure(let error):
                    completion?(false, error)
                }
            }
        }
    }
    
    static func getWallets(completion: WalletsCompletion) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.getWallets(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<WalletsResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.wallets, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func sendWallet(address: WalletData,completion: WalletCompletion) {
        
        let param = AddressesParameters(address: address)
        let request = TemplatesAPIRequest.sendWallets(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<WalletResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.wallet, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func generateWallets(walletsData: [WalletData],completion: Completion) {
        
        let param = WalletsBatchParameters(walletsData: walletsData)
        let request = TemplatesAPIRequest.walletsBatch(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<WalletGeneratedResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success:
                    completion?(true, nil)
                case .failure(let error):
                    completion?(false, error)
                }
            }
        }
    }
    
    static func getTransactions(page: Int = 0, currency: String? = nil, pageSize: Int? = nil, type: TransactionType? = nil, completion: TransactionsCompletion) {
        
        let param = HistoryParameters(page: page, currency: currency, pageSize: pageSize, type: type)
        let request = TemplatesAPIRequest.getTransactions(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<TransactionsResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.transactions, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func pinWallet(id: Int, pin: Bool, completion: Completion) {
        
        let param = WalletIdParameters(walletId: id, pin: pin)
        let request = TemplatesAPIRequest.pin(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<BaseBoolResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success:
                    completion?(true, nil)
                case .failure(let error):
                    completion?(false, error)
                }
            }
        }
    }
    
    static func createTransactionForBitcoin(walletId: Int, address: String, amount: String, completion: CreateBitcoinTransactionsCompletion) {
        
        let param = CreateTransactionParameters(walletId: walletId, address: address, amount: amount)
        let request = TemplatesAPIRequest.createTransaction(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<CreateBitcoinTransactionResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func createTransactionForEthereum(walletId: Int, address: String, amount: String, completion: CreateEthereumTransactionsCompletion) {
        
        let param = CreateTransactionParameters(walletId: walletId, address: address, amount: amount)
        let request = TemplatesAPIRequest.createTransaction(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<CreateEthereumTransactionResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func createTransactionForStellar(walletId: Int, address: String, amount: String, exchangeTag: String?, destinationTag: Int?, completion: CreateStellarTransactionsCompletion) {
        
        var param = CreateTransactionParameters(walletId: walletId, address: address, amount: amount)
        if let exchangeTag = exchangeTag {
                let memo = Memo(memo: exchangeTag)
                param.advancedOptions = memo
        }
        if let destinationTag = destinationTag {
            let memo = Memo(destinationTag: destinationTag)
            param.advancedOptions = memo
        }
        let request = TemplatesAPIRequest.createTransaction(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<CreateStellarTransactionResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func createTransactionForTron(walletId: Int, address: String, amount: String, completion: CreateTronTransactionsCompletion) {
        
        let param = CreateTransactionParameters(walletId: walletId, address: address, amount: amount)
        let request = TemplatesAPIRequest.createTransaction(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<CreateTronTransactionResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func createTransactionForEos(walletId: Int, address: String, amount: String, exchangeTag: String?, completion: CreateEosTransactionsCompletion) {
        
        var param = CreateTransactionParameters(walletId: walletId, address: address, amount: amount)
        if let exchangeTag = exchangeTag {
            let memo = Memo(memo: exchangeTag)
            param.advancedOptions = memo
        }
        let request = TemplatesAPIRequest.createTransaction(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<CreateEosTransactionResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func submitBitcoinTransaction(txHex: String, headersInfo: TransactionHeadersInfo, completion: StringCompletion) {
        
        let param = SubmitBitcoinParameters(txHex: txHex, headersInfo: headersInfo)
        let request = TemplatesAPIRequest.submitBitcoinTransaction(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<TxId>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.txId, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func submitEthereumTransaction(input: TransactionEthereumInput, headersInfo: TransactionHeadersInfo, completion: StringCompletion) {
        
        let param = SubmitEthereumParameters(input: input, headersInfo: headersInfo)
        let request = TemplatesAPIRequest.submitEthereumTransaction(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<TxId>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.txId, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func submitStellarTransaction(signature: String, headersInfo: TransactionHeadersInfo, completion: StringCompletion) {
        
        let param = SubmitStellarParameters(signature: signature, headersInfo: headersInfo)
        let request = TemplatesAPIRequest.submitStellarTransaction(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<TxId>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.txId, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func submitTronTransaction(input: TransactionTronInput, headersInfo: TransactionHeadersInfo, completion: StringCompletion) {
        
        let param = SubmitTronParameters(input: input, headersInfo: headersInfo)
        let request = TemplatesAPIRequest.submitTronTransaction(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<TxId>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.txId, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func submitEosTransaction(input: TransactionEosInput, headersInfo: TransactionHeadersInfo, completion: StringCompletion) {
        
        let param = SubmitEosParameters(input: input, headersInfo: headersInfo)
        let request = TemplatesAPIRequest.submitEosTransaction(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<TxId>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.txId, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func getMaximumBalance(walletId: Int, completion: StringCompletion) {
        
        let param = WalletIdParameters(walletId: walletId)
        let request = TemplatesAPIRequest.maxBalance(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<MaxBalance>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.maxBalance, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func receive(walletId: Int, completion: ReceiveCompletion) {
        
        let param = WalletIdParameters(walletId: walletId)
        let request = TemplatesAPIRequest.receive(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<ReceiveResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.result, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func derivation(_ derivation: Int, address: String, walletId: Int, completion: Completion) {
        
        let param = DerivationParameters(walletId: walletId, address: address, derivation: derivation)
        let request = TemplatesAPIRequest.derivation(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<StringResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success:
                    completion?(true, nil)
                case .failure(let error):
                    completion?(false, error)
                }
            }
        }
    }
    
    static func getMissingWallets(completion: StringArrayCompletion) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.missingWallets(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<MissingWallets>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.missingWallets, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func exchangePrepare(walletFromId: Int, walletToId: Int, amountFrom: String? = nil, amountTo: String? = nil, isWindrawalMain: Bool? = nil, completion: ExchangePrepareCompletion) {
        let exchange = Exchange(walletFromId: walletFromId, walletToId: walletToId, amountFrom: amountFrom, amountTo: amountTo, isWindrawalMain: isWindrawalMain, options: nil)
        let param = ExchangeParameters(exchange: exchange)
        let request = TemplatesAPIRequest.exchangePrepare(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<ExchangePrepareResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.data, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func exchange(walletFromId: Int, walletToId: Int, amountFrom: String, amountTo: String, isWindrawalMain: Bool, options: Options? = nil, completion: ExchangeCompletion) {
        let exchange = Exchange(walletFromId: walletFromId, walletToId: walletToId, amountFrom: amountFrom, amountTo: amountTo, isWindrawalMain: isWindrawalMain, options: options)
        let param = ExchangeParameters(exchange: exchange)
        let request = TemplatesAPIRequest.exchange(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<ExchangeResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.data, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func rates(walletId: Int, period: ChartPeriod, completion: RatesCompletion) {
        
        let param = RatesParameters(walletId: walletId, period: period)
        let request = TemplatesAPIRequest.rates(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<RatesResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.rates, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func checkEosAccount(walletId: Int, account: String, completion: Completion) {
        
        let param = CheckEosAccountParameters(walletId: walletId, account: account)
        let request = TemplatesAPIRequest.checkEosAccount(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<ExistsResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.exists.exists, nil)
                case .failure(let error):
                    completion?(false, error)
                }
            }
        }
    }
    
    static func getNotifications(completion: NotificationsCompletion) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.notifications(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<NotificationsResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.notifications, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func newNotifications(completion: Completion) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.newNotifications(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<BoolResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.data, nil)
                case .failure(let error):
                    completion?(false, error)
                }
            }
        }
    }
    
    static func getReferralAuth(completion: StringCompletion) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.referralAuth(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<AuthResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.data.redirectUrl, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func getReferralUser(completion: ReferralUserCompletion) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.getReferralUser(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<ReferralUserResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.user, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func getReferralInfo(completion: ReferralInfoCompletion) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.getReferralInfo(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<ReferralInfoResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.info, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func getReferrals(completion: ReferralsCompletion) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.getReferrals(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<ReferralsResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.data.items, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func getReferralIncome(completion: ReferralIncomeCompletion) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.getReferralIncome(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<ReferralIncomeResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.data.items, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func getReferralPayments(completion: ReferralPaymentCompletion) {

        let param = EmptyParameters()
        let request = TemplatesAPIRequest.getReferralPayments(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<ReferralPaymentsResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.data.payments, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func getReferralLevels(completion: ReferralLevelsCompletion) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.getReferralLevels(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<ReferralLevelsResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.levels, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func payoutRequest(walletId: Int, completion: Completion) {
        
        let param = WalletIdParameters(walletId: walletId)
        let request = TemplatesAPIRequest.payoutRequest(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<ReferralPaymentsResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success:
                    completion?(true, nil)
                case .failure(let error):
                    completion?(false, error)
                }
            }
        }
    }
    
    static func getTopupCurrencies(completion: TopupCurrenciesCompletion) {
        
        let param = EmptyParameters()
        let request = TemplatesAPIRequest.topupCurrencies(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<CurrenciesResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.data, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func lookupRequest(phone: String, currency: String? = nil, operat: String? = nil, completion: LookupCompletion) {
        
        let param = PhoneParameters(phone: phone, currency: currency, operat: operat)
        let request = TemplatesAPIRequest.topupLookup(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<LookupDataResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.data, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
    
    static func topupValidateEmail(email: String, completion: Completion) {
        
        let param = EmailParameters(email: email)
        let request = TemplatesAPIRequest.topupValidateEmail(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<BaseBoolResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success:
                    completion?(true, nil)
                case .failure(let error):
                    completion?(false, error)
                }
            }
        }
    }
    
    static func createTopup(phone:  String, currency: String, operat: String, amount: String, email: String, completion: TopupCompletion) {
        
        let param = TopupParameters(phone: phone, currency: currency, operat: operat, amount: amount, email: email)
        let request = TemplatesAPIRequest.createTopup(param)
        URLSessionRestApiManager.call(method: request) { (response: Result<TopupDataResponse>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    completion?(result.data, nil)
                case .failure(let error):
                    completion?(nil, error)
                }
            }
        }
    }
}
