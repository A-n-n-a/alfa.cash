//
//  AuthManager.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 06.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import BitcoinKit
import Secp256k1Kit
import CommonCrypto
import CryptorECC
import TrustWalletCore

class WalletManager {
    
    private static var seed: Data?
    
    private static let coins: [TrustWalletCore.CoinType] = [.ethereum, .bitcoin, .bitcoinCash, .eos, .stellar, .litecoin, .tron, .xrp]
    
    static var wallets = [Wallet]() {
        didSet {
            pinnedWallets = wallets.filter({ $0.pinned })
            unpinnedWallets = wallets.filter({ !$0.pinned })
            
            NotificationCenter.default.post(name: Notification.Name.walletsUpdate, object: nil)
        }
    }
    
    static var topupCurrencies = [TopupCurrency]()
    static var defaultTopupCurrency: TopupCurrency? {
        return topupCurrencies.filter({$0.sign == "btc"}).first
    }
    
    static var balance: Double {
        var balance: Double = 0
        for wallet in WalletManager.wallets {
            if let amount = Double(wallet.amount), let price = wallet.price {
                let walletBalance = amount * price
                balance += walletBalance
            }
        }
        return balance
    }
    
    static var pinnedWallets = [Wallet]()
    
    static var unpinnedWallets = [Wallet]()
    
    private static var address: String? {
        if let seed = seed {
            let wallet = HDWallet.init(seed: seed, externalIndex: 0, internalIndex: 0, network: .mainnetBTC)
            let address = wallet.address.description
            #if DEBUG
            print("ADDRESS (BitcoinKit): \(address)")
            #endif
            return address
        }
        return nil
    }
    
    #if DEV
    private static let btcNetwork = Network.testnetBTC
    private static let bchNetwork = Network.testnetBCH
    #else
    private static let btcNetwork = Network.testnetBTC
    private static let bchNetwork = Network.testnetBCH
    #endif
    
    static func checkMnemonic(_ mnemonic: [String]) throws {
        let mnemonicString = mnemonic.joined(separator:" ")
        KeychainWrapper.standart.set(value: mnemonicString, forKey: Constants.Main.udMnemonicString)
        #if DEBUG
        print("MNEMONIC: \(mnemonicString)")
        #endif
        try generateSeed(mnemonic: mnemonic)
    }
    
    private static func generateMnemonic() throws {
        let mnemonic = try Mnemonic.generate()
        KeychainWrapper.standart.setMnemonic(mnemonic)
        let mnemonicString = mnemonic.joined(separator:" ")
        KeychainWrapper.standart.set(value: mnemonicString, forKey: Constants.Main.udMnemonicString)
        #if DEBUG
        print("MNEMONIC: \(mnemonicString)")
        #endif
        
        try generateSeed(mnemonic: mnemonic)
        
    }
    
    private static func generateSeed(mnemonic: [String]) throws {
        let newSeed = try BitcoinKit.Mnemonic.seed(mnemonic: mnemonic)
        seed = newSeed
    }
    
    static func getRegisterAuthData() throws -> AuthData? {
        let mnemonic = try Mnemonic.generate()
        KeychainWrapper.standart.setMnemonic(mnemonic)
        let mnemonicString = mnemonic.joined(separator:" ")
        KeychainWrapper.standart.set(value: mnemonicString, forKey: Constants.Main.udMnemonicString)
        #if DEBUG
        print("MNEMONIC: \(mnemonicString)")
        #endif
        let message = "register"
        
        let newSeed = try BitcoinKit.Mnemonic.seed(mnemonic: mnemonic)
        let wallet = HDWallet(seed: newSeed, externalIndex: 0, internalIndex: 0, network: .mainnetBTC)
        let data = wallet.rootXPubKey.publicKey().pubkeyHash
        let address = try BitcoinAddress(data: data, hashType: .pubkeyHash, network: .mainnetBTC).legacy
        
        guard let signature = Signature(message: message, privateKey: wallet.rootXPrivKey.privateKey().data).sign() else { return nil }

        #if DEBUG
        print("SIGNATURE: ", signature)
        #endif

        let auth = AuthData(username: ApplicationManager.tempUsername, address: address, signature: signature)
        return auth
    }
    
    static func getLoginAuthData(mnemonic: [String]) throws -> AuthData? {
        
        KeychainWrapper.standart.setMnemonic(mnemonic)
        let mnemonicString = mnemonic.joined(separator:" ")
        KeychainWrapper.standart.set(value: mnemonicString, forKey: Constants.Main.udMnemonicString)
        #if DEBUG
        print("MNEMONIC: \(mnemonicString)")
        #endif
        
        let newSeed = try Mnemonic.seed(mnemonic: mnemonic)
        let wallet = HDWallet(seed: newSeed, externalIndex: 0, internalIndex: 0, network: .mainnetBTC)
        let data = wallet.rootXPubKey.publicKey().pubkeyHash
        let address = try BitcoinAddress(data: data, hashType: .pubkeyHash, network: .mainnetBTC).legacy

        #if DEBUG
        print("ADDRESS (BitcoinKit): \(address)")
        #endif

        let message = "login"
        guard let signature = Signature(message: message, privateKey: wallet.rootXPrivKey.privateKey().data).sign() else { return nil}


        #if DEBUG
        print("SIGNATURE: ", signature)
        #endif

        let auth = AuthData(address: address, signature: signature)
        return auth
    }
    
    static func generatedAddresses(coins: [TrustWalletCore.CoinType]? = nil) -> [WalletData]? {
        
        guard let mnemonicString = KeychainWrapper.standart.value(forKey: Constants.Main.udMnemonicString) else { return nil }
        let coinsList = coins ?? WalletManager.coins
        var addresses = [WalletData]()
        let wallet = TrustWalletCore.HDWallet(mnemonic: mnemonicString, passphrase: "")
        #if DEBUG
        print("Mnemonic: ", wallet.mnemonic)
        #endif

        guard let mnemonic = KeychainWrapper.standart.getMnemonic() else { return [] }
 
        for coin in coinsList {
            var address = ""
            switch coin {
            case .bitcoin:
                if let wlt = try? BitcoinKit.HDWallet(mnemonic: mnemonic, passphrase: "", externalIndex: 0, internalIndex: 0, network: btcNetwork) {
                    address = wlt.address.description
                }
            case .litecoin:
                if let wlt = try? BitcoinKit.HDWallet(mnemonic: mnemonic, passphrase: "", externalIndex: 0, internalIndex: 0, network: btcNetwork, account: 2) {
                    address = wlt.address.description
                }
            case .bitcoinCash:
                if let wlt = try? BitcoinKit.HDWallet(mnemonic: mnemonic, passphrase: "", externalIndex: 0, internalIndex: 0, network: btcNetwork, account: 1) {
                    address = wlt.address.description
                }
            default:
                address = wallet.getAddressForCoin(coin: coin)
            }
            let coinName = coin.currency
            let walletData = WalletData(address: address, currency: coinName)
            addresses.append(walletData)
        }
        return addresses
    }
    
    static var recentAddresses = [String]()
    
    static func appendRecentAddress(_ address: String) {
        if var recent = UserDefaults.standard.array(forKey: Constants.Main.udRecentAddresses) as? [String] {
            
            recent.append(address)
            let set = Set(recent)
            var uniqueRecents = Array(set)
            if uniqueRecents.count == 4 {
                uniqueRecents.remove(at: 0)
                
            }
            print("RECENT ADDRESSES: ", uniqueRecents)
            UserDefaults.standard.set(uniqueRecents, forKey: Constants.Main.udRecentAddresses)
        } else {
            UserDefaults.standard.set([address], forKey: Constants.Main.udRecentAddresses)
        }
    }
    
    static func getWalletForBitcoinLikeCoin(_ coin: TrustWalletCore.CoinType) ->  BitcoinKit.HDWallet? {
        
        guard let mnemonic = KeychainWrapper.standart.getMnemonic() else { return nil }
        
        switch coin {
        case .bitcoin:
            return try? BitcoinKit.HDWallet(mnemonic: mnemonic, passphrase: "", externalIndex: 0, internalIndex: 0, network: btcNetwork)
        case .litecoin:
            return try? BitcoinKit.HDWallet(mnemonic: mnemonic, passphrase: "", externalIndex: 0, internalIndex: 0, network: btcNetwork, account: 2)
        case .bitcoinCash:
            return try? BitcoinKit.HDWallet(mnemonic: mnemonic, passphrase: "", externalIndex: 0, internalIndex: 0, network: btcNetwork, account: 1)
        default:
            return nil
        }
    }
    
    static var selectedSpeed: Speed = .medium
    
    static var btcRates = [Rate]()
    static var bchRates = [Rate]()
    static var ltcRates = [Rate]()
    static var ethRates = [Rate]()
    static var xrpRates = [Rate]()
    static var xlmRates = [Rate]()
    static var trxRates = [Rate]()
    static var eosRates = [Rate]()
    
    static func wallet(currency: String) -> Wallet? {
        return wallets.filter({$0.currency == currency}).first
    }
}

struct AuthData {
    var username: String?
    let address: String
    let signature: String
    
    init(username: String? = nil, address: String, signature: String) {
        self.username = username
        self.address = address
        self.signature = signature
    }
}
