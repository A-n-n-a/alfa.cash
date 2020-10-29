// Copyright © 2017-2018 Trust.
//
// This file is part of Trust. The full Trust copyright notice, including
// terms governing use, modification, and redistribution, is contained in the
// file LICENSE at the root of the source code distribution tree.

import Foundation

public final class Tron: Bitcoin {
    override public var coinType: SLIP.CoinType {
        return .tron
    }

    override public var p2shPrefix: UInt8 {
        switch network {
        case .main:
            return 0x41
        case .test:
            return 0xa0
        }
    }

    override public func address(for publicKey: DekuSanPublicKey) -> DecuSanAddress {
        let hash = Data([p2shPrefix]) + DekuSanCrypto.hash(publicKey.data.dropFirst()).suffix(20)
        return DecuSanBitcoinAddress(data: hash)!
    }

    override public init(purpose: DekuSanPurpose = .bip44) {
        super.init(purpose: purpose)
    }
}
