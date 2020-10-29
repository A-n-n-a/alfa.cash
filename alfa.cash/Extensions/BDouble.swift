//
//  BDouble.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 06.05.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

extension BDouble {
    func stringValue() -> String? {
        if let afterDecimalPoint = self.description.components(separatedBy: "/").last {
            let afterPointCount = afterDecimalPoint.count - 1
            let totalString = self.decimalExpansion(precisionAfterDecimalPoint: afterPointCount)
            return totalString
        }
        return nil
    }
}
