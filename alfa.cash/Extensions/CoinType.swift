//
//  CoinType.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 12.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import TrustWalletCore

extension TrustWalletCore.CoinType {
    var currency: String {
        switch self {
            
        case .bitcoin:
            return "btc"
        case .bitcoinCash:
            return "bch"
        case .eos:
            return "eos"
        case .ethereum:
            return "eth"
        case .litecoin:
            return "ltc"
        case .xrp:
            return "xrp"
        case .stellar:
            return "xlm"
        case .ton:
            return "ton"
        case .tron:
            return "trx"
        case .dash:
            return "dash"
        default:
            return ""
        }
    }

    static func getCoin(from string: String) throws -> TrustWalletCore.CoinType? {
        return TrustWalletCore.CoinType.allCases.first(where: { $0.currency == string })
    }
    
    var blockchainExplorerLink: String? {
        switch self {
        case .bitcoin:
            #if DEV
            return "https://chain.so/tx/BTCTEST/"
            #else
            return "https://blockchair.com/bitcoin/transaction/"
            #endif
        case .bitcoinCash:
            #if DEV
            return "https://chain.so/tx/BTCTEST/"
            #else
            return "https://blockchair.com/bitcoin-cash/transaction/"
            #endif
        case .litecoin:
            #if DEV
            return "https://chain.so/tx/BTCTEST/"
            #else
            return "https://insight.litecore.io/tx/"
            #endif
        case .eos:
            #if DEV
            return "https://jungle.bloks.io/transaction/"
            #else
            return "https://bloks.io/transaction/"
            #endif
        case .ethereum:
            #if DEV
            return "https://ropsten.etherscan.io/tx/"
            #else
            return "https://etherscan.io/tx/"
            #endif
        case .xrp:
            #if DEV
            return "https://test.bithomp.com/explorer/"
            #else
            return "https://bithomp.com/explorer/"
            #endif
        case .stellar:
            #if DEV
            return "https://testnet.stellarchain.io/tx/"
            #else
            return "https://stellarchain.io/tx/"
            #endif
        case .tron:
            #if DEV
            return "https://shasta.tronscan.org/#/transaction/"
            #else
            return "https://tronscan.org/#/transaction/"
            #endif
        default:
            return nil
        }
    }
    
    var name: String {
        switch self {
            
        case .bitcoin:
            return "Bitcoin"
        case .bitcoinCash:
            return "BitcoinCash"
        case .eos:
            return "EOS"
        case .ethereum:
            return "Ethereum"
        case .litecoin:
            return "Litecoin"
        case .xrp:
            return "XRP"
        case .stellar:
            return "Stellar"
        case .tron:
            return "Tron"
        case .dash:
            return "Dash"
        default:
            return ""
        }
    }
    
    var image: UIImage? {
        let iconName = ThemeManager.currentTheme == .day ? currency : "\(currency)_dark"
        return UIImage(named: iconName)
    }
}

//extension TrustWalletCore.CoinType: Decodable {
//    public init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        
//        let key = try container.decode(String.self)
//        
//        self = try TrustWalletCore.CoinType.getCoin(from: key)
//    }
//}
