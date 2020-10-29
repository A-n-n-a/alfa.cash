//
//  BiometryManager.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 20.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import LocalAuthentication

enum BiometryType: String {
    case touchID = "Touch ID"
    case faceID = "Face ID"
    case unknown
    
    var image: UIImage? {
        switch self {
        case .touchID:
            return #imageLiteral(resourceName: "touchIdIcn")
        case .faceID:
            return #imageLiteral(resourceName: "faceId")
        default:
            return nil
        }
    }
}

final class BiometryManager {
    typealias FailureCompletion = ((_ errorMessage: String?, _ requiresToReset: Bool, _ isFallback: Bool) -> Void)?
    
    /// Returns Available BiometryType
    class var biometryType: BiometryType {
        let authContext = LAContext()
        let canEvaluate = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        if #available(iOS 11.2, *) {
            var type: LABiometryType = .none
            if authContext.responds(to: #selector(getter: LAContext.biometryType)) {
                type = authContext.biometryType
            }
            if !canEvaluate {
                return .unknown
            }
            
            switch type {
            case .none:
                return .unknown
            case .touchID:
                return .touchID
            case .faceID:
                return .faceID
            @unknown default:
                return .unknown
            }
        } else {
            return canEvaluate ? .touchID : .unknown
        }
    }
    
    /// Returns true, if device supports biometry authentication, otherwise returns false
    class var isBiometryAvailable: Bool {
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
    }
    
    static var isReadyToScanAutomatically: Bool = true
    
    /// Method for setting up Touch ID of Face ID authentication. It's uses LAContext to evaluate it's policy
    ///
    /// - Parameters:
    ///   - policy: Policies specifying which forms of authentication are acceptable. Default is .withBiometrics
    ///   - success: This closure is called only if authentication was successfull
    ///   - failure: This closure is called only if authentication was failed.
    ///              It may contain optional error message.
    ///              The second argument indicates that we need to disable and reset all automatic biometry evaluation
    func authorizeUsingBiometry(_ policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics,
                                success: @escaping () -> Void,
                                failure: FailureCompletion) {
        let context = LAContext()
        var evaluatePolicyError: NSError?
        let reasonDescription = "IOS_BIOMETRY_DESCRIPTION".localized()
        
        if context.canEvaluatePolicy(policy, error: &evaluatePolicyError) {
            context.evaluatePolicy(policy,
                                   localizedReason: reasonDescription,
                                   reply: { (successResponse, evaluationError) in
                                    if successResponse {
                                        success()
                                    } else {
                                        guard let error = evaluationError else {
                                            failure?(nil, false, false)
                                            return
                                        }
                                        
                                        
                                        print(error.localizedDescription)
                                    }
            })
        } else {
            #if DEBUG
            print("Policy error")
            #endif
        }
    }
}

