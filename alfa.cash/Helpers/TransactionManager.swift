//
//  TransactionManager.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 01.04.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import BitcoinKit
import TrustWalletCore
import Secp256k1Kit
import EosioSwift
import EosioSwiftAbieosSerializationProvider
import EosioSwiftSoftkeySignatureProvider
//import HDWalletKit

class TransactionManager {
    
    static var transactions = [ACTransaction]()
    static var shouldUpdateTransactions = true
    static var filtersApplied: Bool {
        return !filters.isEmpty
    }
    static var filters = [Filter]()
    
    static var transactionResponse: CreateTransactionResponseProtocol? {
        didSet {
            //Bitcoin / Lightcoin / BitcoinCash
            if let response = transactionResponse as? CreateBitcoinTransactionResponse {
                
                if response.transactions?.regular == nil && response.transactions?.fast == nil {
                    speed = .slow
                    speedButtonShouldHide = true
                }
                
                switch speed {
                case .fast:
                    transactionBitcoinInput = response.transactions?.fast
                case .medium:
                    transactionBitcoinInput = response.transactions?.regular
                case .slow:
                    transactionBitcoinInput = response.transactions?.slow
                }
            }
            
            // Ethereum
            if let response = transactionResponse as? CreateEthereumTransactionResponse {
                
                if response.transactions?.regular == nil && response.transactions?.fast == nil {
                    speed = .slow
                    speedButtonShouldHide = true
                }
                
                switch speed {
                case .fast:
                    transactionEthereumInput = response.transactions?.fast
                case .medium:
                    transactionEthereumInput = response.transactions?.regular
                case .slow:
                    transactionEthereumInput = response.transactions?.slow
                }
            }
            
            //Stellar
            if let response = transactionResponse as? CreateStellarTransactionResponse {
                transactionStellarInput = response.transactions?.common
            }
            
            //Tron
            if let response = transactionResponse as? CreateTronTransactionResponse {
                transactionTronInput = response.transactions?.common
            }
            
            //Eos
            if let response = transactionResponse as? CreateEosTransactionResponse {
                transactionEosInput = response.transactions?.common
            }
            
            if let metas = transactionResponse?.meta {
                for meta in metas {
                    if meta.value == speed.rawValue {
                        transactionHeaders.fee = meta.fee
                    }
                }
            }
        }
    }
    static var transactionHeaders: TransactionHeadersInfo!
    private static var transactionBitcoinInput: TransactionBitcoinInput?
    private static var transactionEthereumInput: TransactionEthereumInput?
    private static var transactionStellarInput: TransactionStellarInput?
    private static var transactionTronInput: TransactionTronInput?
    private static var transactionEosInput: TransactionEosInput?
    
    static var speed: Speed = .medium
    static var speedButtonShouldHide = false
    static var addresses: [String : Int]?
    static var shouldThrottleError = false
    
    static func feeForSpeed(_ speed: Speed) -> String? {
        guard let metas = transactionResponse?.meta else { return nil }
        for meta in metas {
            if speed.rawValue == meta.value {
                return meta.fee
            }
        }
        if let meta = metas.first {
            return meta.fee
        }
        return nil
    }
    
    static func totalForSpeed(_ speed: Speed) -> String? {
        
        guard let metas = transactionResponse?.meta else { return nil }
        
        for meta in metas {
            if speed.rawValue == meta.value {
                return meta.total
            }
        }
        if let meta = metas.first {
            return meta.total
        }
        return nil
    }
    
    // CREATE TRANSACTION
    
    static func createTransaction(wallet: Wallet, address: String, amount: String, exchangeTag: String? = nil, destinationTag: Int? = nil, completion: @escaping ((Bool) -> Void)) {
        if wallet.currency == "erc20" {
            createTransactionForEthereum(wallet: wallet, address: address, amount: amount) { (success) in
                completion(success)
            }
        } else {
            switch wallet.coin {
            case .bitcoin, .litecoin, .bitcoinCash:
                createTransactionForBitcoin(wallet: wallet, address: address, amount: amount) { (success) in
                    completion(success)
                }
            case .ethereum:
                createTransactionForEthereum(wallet: wallet, address: address, amount: amount) { (success) in
                    completion(success)
                }
            case .stellar:
                createTransactionForStellar(wallet: wallet, address: address, amount: amount, exchangeTag: exchangeTag) { (success) in
                    completion(success)
                }
            case .xrp:
                createTransactionForStellar(wallet: wallet, address: address, amount: amount, destinationTag:  destinationTag) { (success) in
                    completion(success)
                }
            case .tron:
                createTransactionForTron(wallet: wallet, address: address, amount: amount) { (success) in
                    completion(success)
                }
            case .eos:
                createTransactionForEos(wallet: wallet, address: address, amount: amount, exchangeTag: exchangeTag) { (success) in
                    completion(success)
                }
            default:
                break
            }
        }
    }
    
    private static func createTransactionForBitcoin(wallet: Wallet, address: String, amount: String, completion: @escaping ((Bool) -> Void)) {
        NetworkManager.createTransactionForBitcoin(walletId: wallet.id, address: address, amount: amount) { (transactionResponse, error) in
            DispatchQueue.main.async {
                if let error = error, let topVC = UIApplication.topViewController() as? BaseViewController {
                    if shouldThrottleError {
                        shouldThrottleError = false
                    } else {
                        if error.message.isEmpty {
                            topVC.showError("LOW_BALANCE_WARNING".localized())
                        } else {
                            topVC.showError(error)
                        }
                    }
                    completion(false)
                }
                if transactionResponse?.transactions == nil, let topVC = UIApplication.topViewController() as? BaseViewController {
                    if shouldThrottleError {
                        shouldThrottleError = false
                    } else {
                        topVC.showError("LOW_BALANCE_WARNING".localized())
                    }
                    completion(false)
                } else if let transactionResponse = transactionResponse {
                    addresses = transactionResponse.addresses
                    transactionHeaders = TransactionHeadersInfo(wallet: wallet, amount: amount)
                    TransactionManager.transactionResponse = transactionResponse
                    transactionHeaders.addressTo = address
                    completion(true)
                }
                
            }
        }
    }
    
    private static func createTransactionForEthereum(wallet: Wallet, address: String, amount: String, completion: @escaping ((Bool) -> Void)) {
        NetworkManager.createTransactionForEthereum(walletId: wallet.id, address: address, amount: amount) { (transactionResponse, error) in
            DispatchQueue.main.async {
                if let error = error, let topVC = UIApplication.topViewController() as? BaseViewController {
                    if shouldThrottleError {
                        shouldThrottleError = false
                    } else {
                        if error.message.isEmpty {
                            topVC.showError("LOW_BALANCE_WARNING".localized())
                        } else {
                            topVC.showError(error)
                        }
                    }
                    completion(false)
                }
                if transactionResponse?.transactions == nil, let topVC = UIApplication.topViewController() as? BaseViewController {
                    if shouldThrottleError {
                        shouldThrottleError = false
                    } else {
                        topVC.showError("LOW_BALANCE_WARNING".localized())
                    }
                    completion(false)
                } else if let transactionResponse = transactionResponse {
                    transactionHeaders = TransactionHeadersInfo(wallet: wallet, amount: amount)
                    TransactionManager.transactionResponse = transactionResponse
                    transactionHeaders.addressTo = address
                    completion(true)
                }
            }
        }
    }
    
    private static func createTransactionForStellar(wallet: Wallet, address: String, amount: String, exchangeTag: String? = nil, destinationTag: Int? = nil, completion: @escaping ((Bool) -> Void)) {
        NetworkManager.createTransactionForStellar(walletId: wallet.id, address: address, amount: amount, exchangeTag: exchangeTag, destinationTag:  destinationTag) { (transactionResponse, error) in
            DispatchQueue.main.async {
                if let error = error, let topVC = UIApplication.topViewController() as? BaseViewController {
                    if shouldThrottleError {
                        shouldThrottleError = false
                    } else {
                        if error.message.isEmpty {
                            topVC.showError("LOW_BALANCE_WARNING".localized())
                        } else {
                            topVC.showError(error)
                        }
                    }
                    completion(false)
                }
                if transactionResponse?.transactions == nil, let topVC = UIApplication.topViewController() as? BaseViewController {
                    if shouldThrottleError {
                        shouldThrottleError = false
                    } else {
                        topVC.showError("LOW_BALANCE_WARNING".localized())
                    }
                    completion(false)
                } else if let transactionResponse = transactionResponse {
                    transactionHeaders = TransactionHeadersInfo(wallet: wallet, amount: amount)
                    TransactionManager.transactionResponse = transactionResponse
                    transactionHeaders.addressTo = address
                    completion(true)
                }
            }
        }
    }
    
    private static func createTransactionForTron(wallet: Wallet, address: String, amount: String, completion: @escaping ((Bool) -> Void)) {
        NetworkManager.createTransactionForTron(walletId: wallet.id, address: address, amount: amount) { (transactionResponse, error) in
            DispatchQueue.main.async {
                if let error = error, let topVC = UIApplication.topViewController() as? BaseViewController {
                    if shouldThrottleError {
                        shouldThrottleError = false
                    } else {
                        if error.message.isEmpty {
                            topVC.showError("LOW_BALANCE_WARNING".localized())
                        } else {
                            topVC.showError(error)
                        }
                    }
                    completion(false)
                }
                if transactionResponse?.transactions == nil, let topVC = UIApplication.topViewController() as? BaseViewController {
                    if shouldThrottleError {
                        shouldThrottleError = false
                    } else {
                        topVC.showError("LOW_BALANCE_WARNING".localized())
                    }
                    completion(false)
                } else if let transactionResponse = transactionResponse {
                    transactionHeaders = TransactionHeadersInfo(wallet: wallet, amount: amount)
                    transactionHeaders.addressTo = address
                    TransactionManager.transactionResponse = transactionResponse
                    completion(true)
                }
            }
        }
    }
    
    private static func createTransactionForEos(wallet: Wallet, address: String, amount: String, exchangeTag: String?, completion: @escaping ((Bool) -> Void)) {
        NetworkManager.createTransactionForEos(walletId: wallet.id, address: address, amount: amount, exchangeTag: exchangeTag) { (transactionResponse, error) in
            DispatchQueue.main.async {
                if let error = error, let topVC = UIApplication.topViewController() as? BaseViewController {
                    if shouldThrottleError {
                        shouldThrottleError = false
                    } else {
                        if error.message.isEmpty {
                            topVC.showError("LOW_BALANCE_WARNING".localized())
                        } else {
                            topVC.showError(error)
                        }
                    }
                    completion(false)
                }
                if transactionResponse?.transactions == nil, let topVC = UIApplication.topViewController() as? BaseViewController {
                    if shouldThrottleError {
                        shouldThrottleError = false
                    } else {
                        topVC.showError("LOW_BALANCE_WARNING".localized())
                    }
                    completion(false)
                } else if let transactionResponse = transactionResponse {
                    transactionHeaders = TransactionHeadersInfo(wallet: wallet, amount: amount)
                    transactionHeaders.addressTo = address
                    TransactionManager.transactionResponse = transactionResponse
                    completion(true)
                }
            }
        }
    }
    
    //SIGN TRANSACTION
    
    private static func getBitcoinTransactionHexWithDerivation(addresses: [String : Int]?) -> String? {
        
        #if DEV
        var network: INetwork = BTCTestNet()
        #else
        var network: INetwork = BTCMainNet()
        #endif
        var account = 0
        switch TransactionManager.transactionHeaders.currency {
        case .bitcoinCash:
            account = 1
            #if DEV
            network = BCHTestNet()
            #else
            network = BCHMainNet()
            #endif
        case .litecoin:
            account = 2
            #if DEV
            network = LTCTestNet()
            #else
            network = LTCMainNet()
            #endif
        default:
            break
        }
        
        let converter = Base58AddressConverter(addressVersion: network.pubKeyHash, addressScriptVersion: network.scriptHash)
        let scriptConverter = ScriptConverter()
        let segwitConverter =  SegWitBech32AddressConverter(prefix: network.bech32PrefixPattern, scriptConverter: scriptConverter)
        
        guard let rootTransactionHex = transactionBitcoinInput?.txHex,
            let data = Data(hexString: rootTransactionHex),
            let message = TransactionMessageParser().parse(data: data) as? TransactionMessage,
            let mnemonic = KeychainWrapper.standart.getMnemonic() else { return nil }
        
        let seed = Mnemonic.seed(mnemonic: mnemonic)
        
        let messTransaction = message.transaction
        let messInputs = messTransaction.inputs
        
        for input in messInputs {
            
            // FIND INPUT IN RESPONSE WITH TX_ID
            var previousHash = input.previousOutputTxHash
            previousHash.reverse()
            guard let responseInputs = transactionBitcoinInput?.inputs else { return nil}
            
            for responseInput in responseInputs where responseInput.txId == previousHash.hex {
                //GET TRANSACTION WITH INPUT` TX_HEX
                let inputHex = responseInput.txHex
                guard let inputHexData = Data(hexString: inputHex) else { return nil }
                let previousIndex = input.previousOutputIndex
                if let inputTransactionMessage = TransactionMessageParser().parse(data: inputHexData) as? TransactionMessage {
                    let inputTransaction = inputTransactionMessage.transaction
                    
                    //OUTPUT
                    let outputs = inputTransaction.outputs
                    guard outputs.count > previousIndex else {
                        if let topVC = UIApplication.topViewController() as? BaseViewController {
                            topVC.showError("AN_UNEXPECTED_ERROR".localized())
                        }
                        return nil
                    }
                    let output = outputs[previousIndex]
                    let scriptData = output.lockingScript
                    let sequence = input.sequence
                    
                    //DERIVATION
                    #if DEBUG
                    print(addresses ?? "empty addresses")
                    #endif
                    var derivation = 0
                    if output.scriptType == .p2wpkh {
                        derivation = addresses?.first?.value ?? 0
                        if let hash = output.keyHash,
                            let address = try? segwitConverter.convert(keyHash: hash, type: output.scriptType) {
                            #if DEBUG
                            print("SEGWIT ADDRESS: ", address.stringValue)
                            #endif
                        }
                    } else if let hash = output.keyHash,
                        let address = try? converter.convert(keyHash: hash, type: output.scriptType),
                        let value = addresses?[address.stringValue] {
                        derivation = value
                        #if DEBUG
                        print("ADDRESS: ", address.stringValue)
                        #endif
                    }
                    
                    #if DEBUG
                    print("DERIVATION: ", derivation)
                    #endif
                    
                    
                    //SERIALIZERS
                    let networkMessageParser = NetworkMessageParser(magic: network.magic)
                    let networkMessageSerializer = NetworkMessageSerializer(magic: network.magic)
                    let serializer = TransactionMessageSerializer()
                    networkMessageSerializer.add(serializer: serializer)
                    let factory = Factory(network: network, networkMessageParser: networkMessageParser, networkMessageSerializer: networkMessageSerializer)
                    
                    do {
                        
                        //WALLET, PUBLIC KEY
                        let hdWallet = SegwitHDWallet(seed: seed, coinType: network.coinType, xPrivKey: network.xPrivKey, xPubKey: network.xPubKey)
                        let publickKey = try hdWallet.publicKey(account: account, index: derivation, external: true)
                        
                        //UNSPENT OUTPUT
                        let unspentOutput = UnspentOutput(output: output, publicKey: publickKey, transaction: inputTransaction.header)
                        
                        //INPUT TO SIGN
                        let inputToSign = factory.inputToSign(withPreviousOutput: unspentOutput, script: scriptData, sequence: sequence)
                        
                        //MUTABLE TRANSACTION
                        let mutableTransaction = MutableTransaction()
                        mutableTransaction.outputs = messTransaction.outputs
                        mutableTransaction.add(inputToSign: inputToSign)
                        
                        //SIGN
                        let inputSigner = InputSigner(hdWallet: hdWallet, network: network)
                        let transactionSigner = TransactionSigner(inputSigner: inputSigner)
                        try transactionSigner.sign(mutableTransaction: mutableTransaction)
                        
                        //TRANSACTION HEX
                        let trans = TransactionMessage(transaction: mutableTransaction.build(), size: 0)
                        let txHex = serializer.serialize(message: trans)?.hex
                        return txHex
                        
                    } catch {
                        print("ERROR: ", error)
                    }
                }
            }
        }
        return nil
    }
    
    private static func prepareEthereumInputSuccessfully() -> Bool {
        guard let ethereumInput = TransactionManager.transactionEthereumInput,
            let mnemonicString = KeychainWrapper.standart.value(forKey: Constants.Main.udMnemonicString)
            else { return false }
        
        let wlt = TrustWalletCore.HDWallet(mnemonic: mnemonicString, passphrase: "")
        let key = wlt.getKeyForCoin(coin: .ethereum)
        
        let input = EthereumSigningInput.with {
            #if DEV
            let chainIdHex = "03"
            #else
            let chainIdHex = "01"
            #endif
            $0.chainID = Data(hexString: chainIdHex)!
            $0.nonce = ethereumInput.nonce.toByteStringAmount()
            $0.gasPrice = ethereumInput.gasPrice.toByteStringAmount()
            $0.gasLimit = ethereumInput.gas.toByteStringAmount()
            $0.toAddress = ethereumInput.to
            $0.amount = ethereumInput.value.toByteStringAmount()
            $0.privateKey = key.data.toByteStringData()
            $0.payload = Data(hexReduced: ethereumInput.input)
        }
        
        let output: EthereumSigningOutput = AnySigner.sign(input: input, coin: .ethereum)
        TransactionManager.transactionEthereumInput?.v = output.v.toByteString()
        TransactionManager.transactionEthereumInput?.r = output.r.toByteString()
        TransactionManager.transactionEthereumInput?.s = output.s.toByteString()
        return true
    }
    
    private static func getRippleSignature(destinationTag: Int?) -> String? {
        
        guard let rippleInput = TransactionManager.transactionStellarInput,
            let mnemonicString = KeychainWrapper.standart.value(forKey: Constants.Main.udMnemonicString)
            else { return nil }
        
        let wlt = TrustWalletCore.HDWallet(mnemonic: mnemonicString, passphrase: "")
        let key = wlt.getKeyForCoin(coin: .xrp)
        
        let input = RippleSigningInput.with {
            $0.amount = rippleInput.amount.toInt64()!
            $0.fee = rippleInput.fee.toInt64()!
            $0.sequence = Int32(rippleInput.sequence)
            $0.account = rippleInput.account
            $0.destination = rippleInput.destination
            $0.privateKey = key.data
            if let destinationTag = destinationTag {
                $0.destinationTag = Int64(destinationTag)
            }
        }
        
        let output: RippleSigningOutput = AnySigner.sign(input: input, coin: .xrp)
        #if DEBUG
        print(output.encoded.hexString)
        #endif
        return output.encoded.hexString
    }
    
    private static func prepareTronInputSuccessfully() -> Bool {
        
        guard let tronInput = TransactionManager.transactionTronInput,
            let mnemonicString = KeychainWrapper.standart.value(forKey: Constants.Main.udMnemonicString)
            else {
                return false
        }
        
        let wallet = DecuSanHDWallet(mnemonic: mnemonicString)
        let privateKey = wallet.getKey(at: Tron().derivationPath(at: 0))
            
        if let hashSigner = Data(hexString: tronInput.rawDataHex) {
            let hash = DekuSanCrypto.sha256(hashSigner)
            let signature = DekuSanCrypto.sign(hash: hash, privateKey: privateKey.data)
            print(signature.hexString)
            TransactionManager.transactionTronInput?.signature = [signature.hexString]
            return true
        }
        
        return false
    }
    
    private static func prepareEosInputSuccessfully() -> Bool {
        
        guard let eosInput = TransactionManager.transactionEosInput,
            let mnemonicString = KeychainWrapper.standart.value(forKey: Constants.Main.udMnemonicString)
            else { return false }
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        let wlt = TrustWalletCore.HDWallet(mnemonic: mnemonicString, passphrase: "")
        let privateKey = TrustWalletCore.Base58.encode(data: wlt.getKeyForCoin(coin: .eos).data)
        
        let provider = EosioAbieosSerializationProvider()
        let pubKeys = [wlt.getAddressForCoin(coin: .eos)]
        
        do {

            let tr = EosioTransaction()
            tr.serializationProvider = provider
            tr.signatureProvider = try EosioSoftkeySignatureProvider(privateKeys: [privateKey])
            
            for action in eosInput.actions {

                let jsonData = try encoder.encode(action)
                let jsonString = String(data: jsonData, encoding: .utf8)!
                print(jsonString)
                let decoder = JSONDecoder()
                let action = try decoder.decode(EosioTransaction.Action.self, from: jsonData)
                tr.add(action: action)
            }
            
            tr.expiration = Date(yyyyMMddTHHmmss: eosInput.expiration + ".000")!
            tr.delaySec = UInt(eosInput.delaySec)
            tr.maxCpuUsageMs = UInt(eosInput.maxCpuUsageMs)
            tr.maxNetUsageWords = UInt(eosInput.maxNetUsageWords)
            tr.refBlockNum = UInt16(eosInput.refBlockNum)
            tr.refBlockPrefix = UInt64(eosInput.refBlockPrefix)
            #if DEV
            tr.chainId = "e70aaab8997e1dfce58fbfac80cbbb8fecec7b99cf982a9444273cbc64c41473"
            #else
            tr.chainId = "aca376f206b8fc25a6ed44dbdc66547c36c6c33e3a119ffbeaef943642f0e906"
            #endif
            
            tr.sign(publicKeys: pubKeys) { (response) in
                if let signatures = tr.signatures {
                    TransactionManager.transactionEosInput?.signatures = signatures
                }
            }

        } catch {
            print(error)
            return false
        }
        
        return true
    }
    
    private static func getStellarSignature(memo: String?) -> String? {
        
        guard let stellarInput = TransactionManager.transactionStellarInput,
            let mnemonicString = KeychainWrapper.standart.value(forKey: Constants.Main.udMnemonicString)
            else { return nil }
        
        let wlt = TrustWalletCore.HDWallet(mnemonic: mnemonicString, passphrase: "")
        let key = wlt.getKeyForCoin(coin: .stellar)
        
        let input = StellarSigningInput.with {
            #if DEV
            $0.passphrase = "Test SDF Network ; September 2015"
            #else
            $0.passphrase = "Public Global Stellar Network ; September 2015"
            #endif
            $0.amount = stellarInput.amount.toInt64()!
            $0.fee = stellarInput.fee.toInt32()!
            $0.sequence = Int64(stellarInput.sequence + 1)
            $0.account = stellarInput.account
            $0.destination = stellarInput.destination
            $0.privateKey = key.data
            $0.operationType = .payment
            
            if let memo = memo {
                var memoText = TW_Stellar_Proto_MemoText()
                memoText.text = memo
                $0.memoText = memoText
            }
        }
        
        let output: StellarSigningOutput = AnySigner.sign(input: input, coin: .stellar)
        #if DEBUG
        print("STELLAR SIGNATURE: ", output.signature)
        #endif
        
        return output.signature
    }
    
    //SUBMIT TRANSACTION
    
    static func submitTransaction(orderId: String? = nil, eosActivationId: Int? = nil, destinationTag: Int? = nil, exchangeTag: String? = nil, completion: @escaping ((String?) -> Void)) {
        
        switch TransactionManager.transactionHeaders.currency {
        case .bitcoin, .litecoin, .bitcoinCash:
            submitBitcoin(orderId: orderId, eosActivationId: eosActivationId, completion: { (txId) in
                completion(txId)
            })
        case .ethereum:
            submitEthereum(orderId: orderId, eosActivationId: eosActivationId, completion:  { (txId) in
                completion(txId)
            })
        case .stellar:
            submitStellar(orderId: orderId, eosActivationId: eosActivationId, exchangeTag: exchangeTag, completion:  { (txId) in
                completion(txId)
            })
        case .xrp:
            submitRipple(orderId: orderId, eosActivationId: eosActivationId, destinationTag: destinationTag, completion:  { (txId) in
                completion(txId)
            })
        case .tron:
            submitTron(orderId: orderId, eosActivationId: eosActivationId) { (txId) in
                completion(txId)
            }
        case .eos:
            submitEos(orderId: orderId, eosActivationId: eosActivationId) { (txId) in
                completion(txId)
            }
        default:
            submitEthereum(orderId: orderId, eosActivationId: eosActivationId, completion:  { (txId) in
                completion(txId)
            })
            break
        }
    }
    
    private static func submitBitcoin(orderId: String?, eosActivationId: Int?, completion: @escaping ((String?) -> Void)) {
        
        if let txHex = getBitcoinTransactionHexWithDerivation(addresses: addresses)  {
            TransactionManager.transactionHeaders.orderId = orderId
            TransactionManager.transactionHeaders.eosActivationId = eosActivationId
            NetworkManager.submitBitcoinTransaction(txHex: txHex, headersInfo: TransactionManager.transactionHeaders) { (txId, error) in
                DispatchQueue.main.async {
                    if let error = error, let topVC = UIApplication.topViewController() as? BaseViewController {
                        topVC.showError(error)
                        completion(nil)
                    }
                    completion(txId)
                }
            }
        } else if let topVC = UIApplication.topViewController() as? BaseViewController {
            completion(nil)
            topVC.showError("Something went wrong")
        }
    }
    
    private static func submitEthereum(orderId: String?, eosActivationId: Int?, completion: @escaping ((String?) -> Void)) {
        if TransactionManager.prepareEthereumInputSuccessfully(), let input = TransactionManager.transactionEthereumInput {
            TransactionManager.transactionHeaders.orderId = orderId
            TransactionManager.transactionHeaders.eosActivationId = eosActivationId
            NetworkManager.submitEthereumTransaction(input: input, headersInfo: TransactionManager.transactionHeaders) { (txId, error) in
                DispatchQueue.main.async {
                    if let error = error, let topVC = UIApplication.topViewController() as? BaseViewController {
                        topVC.showError(error)
                        completion(nil)
                    }
                    completion(txId)
                }
            }
        }
    }
    
    private static func submitStellar(orderId: String?, eosActivationId: Int?, exchangeTag: String?, completion: @escaping ((String?) -> Void)) {
        if let signature = TransactionManager.getStellarSignature(memo: exchangeTag) {
            submitStellarRipple(orderId: orderId, signature: signature, eosActivationId: eosActivationId) { (txId) in
                completion(txId)
            }
        }
    }
    
    private static func submitRipple(orderId: String?, eosActivationId: Int?, destinationTag: Int?, completion: @escaping ((String?) -> Void)) {
        if let signature = TransactionManager.getRippleSignature(destinationTag: destinationTag) {
            submitStellarRipple(orderId: orderId, signature: signature, eosActivationId: eosActivationId) { (txId) in
                completion(txId)
            }
        }
    }
    
    private static func submitTron(orderId: String?, eosActivationId: Int?, completion: @escaping ((String?) -> Void)) {
        if TransactionManager.prepareTronInputSuccessfully(),
            let input = TransactionManager.transactionTronInput {
            TransactionManager.transactionHeaders.orderId = orderId
            TransactionManager.transactionHeaders.eosActivationId = eosActivationId
            NetworkManager.submitTronTransaction(input: input, headersInfo: TransactionManager.transactionHeaders) { (txId, error) in
                DispatchQueue.main.async {
                    if let error = error, let topVC = UIApplication.topViewController() as? BaseViewController {
                        topVC.showError(error)
                        completion(nil)
                    }
                    completion(txId)
                }
            }
        }
    }
    
    private static func submitEos(orderId: String?, eosActivationId: Int?, completion: @escaping ((String?) -> Void)) {
        if TransactionManager.prepareEosInputSuccessfully(),
            let input = TransactionManager.transactionEosInput {
            TransactionManager.transactionHeaders.orderId = orderId
            TransactionManager.transactionHeaders.eosActivationId = eosActivationId
            NetworkManager.submitEosTransaction(input: input, headersInfo: TransactionManager.transactionHeaders) { (txId, error) in
                DispatchQueue.main.async {
                    if let error = error, let topVC = UIApplication.topViewController() as? BaseViewController {
                        topVC.showError(error)
                        completion(nil)
                    }
                    completion(txId)
                }
            }
        }
    }
    
    private static func submitStellarRipple(orderId: String?, signature:  String, eosActivationId: Int?, completion: @escaping ((String?) -> Void)) {
        TransactionManager.transactionHeaders.orderId = orderId
        TransactionManager.transactionHeaders.eosActivationId = eosActivationId
        NetworkManager.submitStellarTransaction(signature: signature, headersInfo: TransactionManager.transactionHeaders) {(txId, error) in
            DispatchQueue.main.async {
                if let error = error, let topVC = UIApplication.topViewController() as? BaseViewController {
                    topVC.showError(error)
                    completion(nil)
                }
                completion(txId)
            }
        }
    }
}

struct TransactionHeadersInfo {
    var wallet: Wallet
    var amount: String = ""
    var fee: String = ""
    var total: String = ""
    var currency: TrustWalletCore.CoinType?
    var orderId: String? = nil
    var addressTo: String?
    var eosActivationId: Int? = nil
    var topupOrderId: String?
    
    init(wallet: Wallet, amount: String) {
        self.wallet = wallet
        self.amount = amount
        self.currency = wallet.coin 
    }
}

extension TransactionHeadersInfo {
    var requestHeaders: [String : String] {
        
        var headers: [String : String] = ["currency" : self.currency?.currency ?? "erc20",
                                          "x-tx-amount" : self.amount,
                                          "x-tx-fee" : self.fee,
                                          "x-tx-total" : self.total,
                                          "x-tx-wallet-id" : "\(self.wallet.id)"]
        if let orderId =  self.orderId {
            headers["x-tx-exchange-order"] = orderId
        }
        if let eosActivationId = self.eosActivationId {
            headers["x-tx-eos-activation-id"] = "\(eosActivationId)"
        }
        if let orderId =  self.topupOrderId {
            headers["x-tx-topup-order-id"] = orderId
        }
        
        if let addressTo = addressTo {
            headers["x-tx-to"] = addressTo
        }
        
        return headers
    }
}
