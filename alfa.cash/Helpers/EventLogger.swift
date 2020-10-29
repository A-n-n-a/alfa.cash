//
//  EventLogger.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 22.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
//import Crashlytics
//import FirebaseAnalytics
//import AppsFlyerLib
import StoreKit
//import FBSDKCoreKit

enum IssueSeverity: Int {
    case error = 1
    case warning = 2
    case info = 3
    
    var infoValue: String {
        switch self {
        case .error:
            return "error"
        case .warning:
            return "warning"
        case .info:
            return "info"
        }
    }
}

enum IssueType: String {
    case undefined = "Undefined"
//    case migration = "Database Migration"
//    case dataCorruption = "Data Corruption"
    case keychain = "Keychain"
}

final class EventLogger {
    //=========================================================
    // MARK: - Variables
    //=========================================================
    var paymentType: String?
    var paymentName: String?
    var paymentAmount: Double?
    var paymentComission: Double?
    var incompletePaymentType: String?
    var totalAmount: Double?

    //=========================================================
    // MARK: - Crashlytics
    //=========================================================
    class func log(issue: String,
                   severity: IssueSeverity,
                   type: IssueType = .undefined,
                   info: [String: Any]? = nil) {
        let issueInfo = [NSLocalizedDescriptionKey: issue,
                         "Severity": "\(severity.infoValue)",
            "Type": "\(type.rawValue)"]
        
        let error = NSError(domain: "\(type.rawValue). \(issue) [\(severity.infoValue)]",
            code: severity.rawValue, userInfo: issueInfo)
        log(error: error, info: info)
    }
    
    //=========================================================
    // MARK: - Analytics
    //=========================================================
    init(name: String?) {
        self.paymentName = name
    }
    
    init(incompletePaymentType: String) {
        self.incompletePaymentType = incompletePaymentType
    }

    init() {
        
    }
    
    class func log(error: Error, info: [String: Any]? = nil) {
        #if DEBUG
            print(" >>> [EventLogger] \(String(describing: error)). Info: \(String(describing: info))")
        #endif
//        Crashlytics.sharedInstance().recordError(error, withAdditionalUserInfo: info)
    }
}

