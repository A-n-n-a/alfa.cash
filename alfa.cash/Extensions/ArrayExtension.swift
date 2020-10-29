//
//  Array.swift
//  alfa.cash
//
//  Created by Anna on 7/7/20.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

extension Array where Element == Rate {
    
    func maxRate() -> Rate? {
        guard !self.isEmpty else { return nil }
        var max = self.first!
        for rate in self {
            if max.price < rate.price {
                max = rate
            }
        }
        return max
    }
    
    func minRate() -> Rate? {
        guard !self.isEmpty else { return nil }
        var min = self.first!
        for rate in self {
            if min.price > rate.price {
                min = rate
            }
        }
        return min
    }
}
