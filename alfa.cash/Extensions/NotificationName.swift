//
//  NotificationName.swift
//  alfa.cash
//
//  Created by Anna Alimanova on 20.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

extension NSNotification.Name {
    static var walletsUpdate: NSNotification.Name {
        return NSNotification.Name(rawValue: "WalletsUpdated")
    }
    
    static var showHistory: NSNotification.Name {
        return NSNotification.Name(rawValue: "ShowHistory")
    }
    
    static var iCloudBackupError: NSNotification.Name {
        return NSNotification.Name(rawValue: "iCloudBackupError")
    }
    
    static var iCloudBackupSuccess: NSNotification.Name {
        return NSNotification.Name(rawValue: "iCloudBackupSuccess")
    }
}
