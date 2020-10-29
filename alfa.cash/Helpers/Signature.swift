//
//  Signature.swift
//  AlfaCash
//
//  Created by Ihor on 06.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import BitcoinKit
import CommonCrypto
import CryptoKit
import Secp256k1Kit

class Signature {
    private let key: Data
    private let message: String

    public init(message: String, privateKey: Data) {
        self.key = privateKey
        self.message = message
    }

    public func sign() -> String? {
        let signingData = message.prepareForBTCSigning().sha256.sha256
        let signature = compactSignature(for: signingData, key: key)
        return signature?.base64EncodedString()
    }

    private func compactSignature(for hash: Data, key: Data?) -> Data? {
        var signature: Data?

        guard let key = key else {
            return nil
        }

        var len = 65
        var sig = UnsafeMutablePointer<UInt8>.allocate(capacity: len)
        sig.initialize(repeating: 0, count: len) // 初始全为0
        var s = UnsafeMutablePointer<secp256k1_ecdsa_recoverable_signature>.allocate(capacity: 1)
        var recid: Int32 = 0

        defer {
            s.deinitialize(count: 1)
            s.deallocate()

            sig.deinitialize(count: len)
            sig.deallocate()
        }

        guard secp256k1_ecdsa_sign_recoverable(
            ctx,
            s,
            hash.u8,
            key.u8,
            secp256k1_nonce_function_rfc6979,
            nil
        ) > 0 else {
            return nil
        }
        guard secp256k1_ecdsa_recoverable_signature_serialize_compact(
            ctx,
            sig.advanced(by: 1),
            &recid, s
        ) > 0 else {
            return nil
        }

        sig.pointee = UInt8(27 + Int(recid) + (4))
        signature = Data(bytes: sig, count: len)

        return signature
    }
    
    var ctx: OpaquePointer {
        return secp256k1_context_create(UInt32(SECP256K1_CONTEXT_SIGN | SECP256K1_CONTEXT_VERIFY))!
    }
}


public extension String {
    func prepareForBTCSigning() -> Data {
        var data = Data()
        data.appendVarString(value: "Bitcoin Signed Message:\n")
        data.appendVarString(value: self)
        return data
    }
}

private extension Data {
    var u8: Array<UInt8> {
        return Array(self)
    }

    func hexString(_ iterator: Array<UInt8>.Iterator) -> String {
        return iterator.map { String(format: "%02x", $0) }.joined()
    }

    var sha256: Data {
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes({
            _ = CC_SHA256($0, CC_LONG(self.count), &digest)
        })
        return Data(digest)
    }

    mutating func appendVarString(value: String) {
        let strData = value.data(using: String.Encoding.utf8) ?? Data()
        appendVarInt(value: strData.count)
        append(strData)
    }

    mutating func appendVarInt(value: Int) {
        if value < 0 {
            return
        }

        if value < 0xFD {
            append(UInt8(value))
        } else if value <= 0xFFFF {
            append(0xFD)
            var compactValue: UInt16 = UInt16(value).littleEndian
            let compactData = Data(bytes: &compactValue, count: MemoryLayout<UInt16>.size)
            append(compactData)
        } else if value <= 0xFFFFFFFF {
            append(0xFE)
            var compactValue: UInt32 = UInt32(value).littleEndian
            let compactData = Data(bytes: &compactValue, count: MemoryLayout<UInt32>.size)
            append(compactData)
        } else {
            append(0xFF)
            var compactValue: UInt64 = UInt64(value).littleEndian
            let compactData = Data(bytes: &compactValue, count: MemoryLayout<UInt64>.size)
            append(compactData)
        }
    }
}
