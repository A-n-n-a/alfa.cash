//
//  Logger.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 05.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

class ACLogger {
    
    static func log(_ info: String) {
        print("\n\n-------------------------------------------------------------")
        print(" >>> [Logger] >>> \(info) ")
        print("\n\n-------------------------------------------------------------")
    }
}
