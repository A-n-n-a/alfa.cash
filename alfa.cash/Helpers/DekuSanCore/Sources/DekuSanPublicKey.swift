// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public struct DekuSanPublicKey: Hashable, CustomStringConvertible {
    /// Compressed public key size.
    public static let compressedSize = 33

    /// Uncompressed public key size.
    public static let uncompressedSize = 65

    /// Validates that raw data is a valid public key.
    static public func isValid(data: Data) -> Bool {
        switch data.first {
        case 2, 3:
            return data.count == DekuSanPublicKey.compressedSize
        case 4, 6, 7:
            return data.count == DekuSanPublicKey.uncompressedSize
        default:
            return false
        }
    }

    /// Raw representation of the public key.
    public let data: Data

    /// Whether this is a compressed key.
    public var isCompressed: Bool {
        return data.count == DekuSanPublicKey.compressedSize && data[0] == 2 || data[0] == 3
    }

    /// Returns the compressed public key.
    public var compressed: DekuSanPublicKey {
        if isCompressed {
            return self
        }
        let prefix: UInt8 = 0x02 | (data[64] & 0x01)
        return DekuSanPublicKey(data: Data(bytes: [prefix]) + data[1 ..< 33])!
    }

    /// Creates a public key from a raw representation.
    public init?(data: Data) {
        if !DekuSanPublicKey.isValid(data: data) {
            return nil
        }
        self.data = data
    }

    public var description: String {
        return data.hexString
    }

    // MARK: Hashable

    public static func == (lhs: DekuSanPublicKey, rhs: DekuSanPublicKey) -> Bool {
        return lhs.data == rhs.data
    }

    public var hashValue: Int {
        return data.hashValue
    }
}
