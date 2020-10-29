//
//  Data.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 11.03.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation
import CryptoSwift

extension Data {
    
    func toByteString() -> String {
        return "0x\(self.hex)"
    }
    
    func toByteStringData() -> Data {
        return Data(hexString: "0x\(self.hex)")!
    }
    
    public init(hexReduced: String) {
        self.init(Array<UInt8>(hex: hexReduced))
    }
}
