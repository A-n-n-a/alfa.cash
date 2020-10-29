//
//  TransactionResponces.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 12.03.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

// protocol
struct CreateBitcoinTransactionResponse: Decodable, CreateTransactionResponseProtocol {
    var prioritySupport: Bool
    var transactions: CreatedBitcoinTransactions?
    var meta: [Meta]
    var addresses: [String: Int]?
}

struct CreateEthereumTransactionResponse: Decodable, CreateTransactionResponseProtocol {
    var prioritySupport: Bool
    var transactions: CreatedEthereumTransactions?
    var meta: [Meta]
}

struct CreateStellarTransactionResponse: Decodable, CreateTransactionResponseProtocol {
    var prioritySupport: Bool
    var transactions: CreatedStellarTransactions?
    var meta: [Meta]
}

struct CreateTronTransactionResponse: Decodable, CreateTransactionResponseProtocol {
    var prioritySupport: Bool
    var transactions: CreatedTronTransactions?
    var meta: [Meta]
}

struct CreateEosTransactionResponse: Decodable, CreateTransactionResponseProtocol {
    var prioritySupport: Bool
    var transactions: CreatedEosTransactions?
    var meta: [Meta]
}

//Bitcoin / Litecoin / Bitcoin Cash

struct CreatedBitcoinTransactions: Decodable {
    let fast: TransactionBitcoinInput?
    let regular: TransactionBitcoinInput?
    let slow: TransactionBitcoinInput
}

struct TransactionBitcoinInput: Decodable {
    let inputs: [BitcoinInput]
    let txHex: String
    let txHash: String
    let fee: Int
    
    enum CodingKeys: String, CodingKey {
        case inputs
        case txHex = "tx_hex"
        case txHash = "tx_hash"
        case fee
    }
}

struct BitcoinInput: Decodable {
    let txId: String
    let txHex: String
    let index: Int
    
    enum CodingKeys: String, CodingKey {
        case txId = "tx_id"
        case txHex = "tx_hex"
        case index
    }
}


// Ethereum

struct CreatedEthereumTransactions: Decodable {
    let fast: TransactionEthereumInput?
    let regular: TransactionEthereumInput?
    let slow: TransactionEthereumInput
}

struct TransactionEthereumInput: Codable {
    let gas: String
    let gasPrice: String
    let hash: String
    let input: String
    let nonce: String
    var r: String
    var s: String
    var v: String
    let to: String
    let value: String
}


//Stellar

struct CreatedStellarTransactions: Decodable {
    let common: TransactionStellarInput
}

struct CreatedTronTransactions: Decodable {
    let common: TransactionTronInput
}

struct TransactionStellarInput: Decodable {
    let account: String
    let amount: String
    let destination: String
    let fee: String
    let flags: Int
    let sequence: Int
    let transactionType: String
    
    enum CodingKeys: String, CodingKey {
        case account = "Account"
        case amount = "Amount"
        case destination = "Destination"
        case fee = "Fee"
        case flags = "Flags"
        case sequence = "Sequence"
        case transactionType = "TransactionType"
    }
}

struct TransactionTronInput: Codable {
    let rawData: TronRowData
    let visible: Bool
    let txID: String
    let rawDataHex: String
    var signature: [String]?
    
    enum CodingKeys: String, CodingKey {
        case rawData = "raw_data"
        case visible
        case txID
        case rawDataHex = "raw_data_hex"
        case signature
    }
}

struct TronRowData: Codable {
    
    var contract: [TronContractField]
    var expiration: Int
    var refBlockBytes: String
    var refBlockHash: String
    var timestamp: Int
    
    enum CodingKeys: String, CodingKey {
        case contract
        case expiration
        case refBlockBytes = "ref_block_bytes"
        case refBlockHash = "ref_block_hash"
        case timestamp
    }
}

struct TronContractField: Codable {
    var parameter: TronParameter
    var type: String
}

struct TronParameter: Codable {
    var value: TronValue
    var typeUrl: String
    
    enum CodingKeys: String, CodingKey {
        
        case value
        case typeUrl = "type_url"
    }
}

struct TronValue: Codable {
    var amount: Int
    var ownerAddress: String
    var toAddress: String
    
    enum CodingKeys: String, CodingKey {
        
        case amount
        case ownerAddress = "owner_address"
        case toAddress = "to_address"
    }
}

struct CreatedEosTransactions: Decodable {
    let common: TransactionEosInput
}

struct TransactionEosInput: Codable {
    let actions: [EosAction]
    let contextFreeActions: [String]
    let contextFreeData: [String]
    let delaySec: Int
    let expiration: String
    let maxCpuUsageMs: Int
    let maxNetUsageWords: Int
    let refBlockNum: Int
    let refBlockPrefix: Int
    var signatures: [String]
    let transactionExtensions: [String]
    
    enum CodingKeys: String, CodingKey {
        
        case actions
        case contextFreeActions = "context_free_actions"
        case contextFreeData = "context_free_data"
        case delaySec = "delay_sec"
        case expiration
        case maxCpuUsageMs = "max_cpu_usage_ms"
        case maxNetUsageWords = "max_net_usage_words"
        case refBlockNum = "ref_block_num"
        case refBlockPrefix = "ref_block_prefix"
        case signatures
        case transactionExtensions = "transaction_extensions"
    }
}

struct EosAction: Codable {
    let account: String
    let authorization: [EosAuthorization]
    let data: String
    let name: String
}

struct EosAuthorization: Codable {
    let actor: String
    let permission: String
}

struct TxId: Decodable {
    let txId: String
    
    enum CodingKeys: String, CodingKey {
        case txId = "tx_id"
    }
}

struct MaxBalance: Decodable {
    let maxBalance: String
    
    enum CodingKeys: String, CodingKey {
        case maxBalance = "data"
    }
}

struct MissingWallets: Decodable {
    let missingWallets: [String]
    
    enum CodingKeys: String, CodingKey {
        case missingWallets = "data"
    }
}

struct Exists: Decodable {
    let exists: Bool
}

struct ExistsResponse: Decodable {
    let exists: Exists
    
    enum CodingKeys: String, CodingKey {
        case exists = "data"
    }
}
