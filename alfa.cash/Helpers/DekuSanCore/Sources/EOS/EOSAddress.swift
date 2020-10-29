// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public struct EOSAddress: DecuSanAddress {

    static let prefix: String = "EOS"

    public let data: Data

    public static func isValid(data: Data) -> Bool {
        return data.count == 37
    }

    public static func isValid(string: String) -> Bool {
        guard let decoded = EOSAddress.decode(string: string) else {
            return false
        }
        return EOSAddress.isValid(data: decoded)
    }

    public static func decode(string: String) -> Data? {
        guard string.starts(with: EOSAddress.prefix) else {
            return nil
        }
        let sub = String(string.dropFirst(EOSAddress.prefix.count))
        guard let decoded = DekuSanCrypto.base58DecodeRaw(sub) else {
            return nil
        }
        return decoded
    }

    public init?(data: Data) {
        if !EOSAddress.isValid(data: data) {
            return nil
        }
        self.data = data
    }

    public init?(string: String) {
        guard let decoded = EOSAddress.decode(string: string) else {
            return nil
        }
        self.data = decoded
    }

    public var description: String {
        return EOSAddress.prefix + DekuSanCrypto.base58EncodeRaw(data)
    }
}
