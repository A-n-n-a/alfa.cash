//
//  KeychainWrapper.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 22.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit
import Security

struct UserAuthData {
    var username: String?
    var passcode: String
}

class KeychainWrapper {
    
    public static let standart = KeychainWrapper()
    private let serviceName = "AlfaCash.Service"
    
    @discardableResult func set(value: String, forKey key: String) -> Bool {
        guard let encodedPassword = value.data(using: String.Encoding.utf8) else {
            return false
        }
        
        if self.value(forKey: key) != nil {
            return update(value: value, forKey: key)
        } else {
            var newItem = KeychainWrapper.queryGenericPassword(withService: key,
                                                  account: key)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?
            
            let status = SecItemAdd(newItem as CFDictionary, nil)
            guard status == noErr else {
                return false
            }
        }
        
        return true
    }
    
    func value(forKey key: String) -> String? {
        var query = KeychainWrapper.queryGenericPassword(withService: key,
                                                           account: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status != errSecItemNotFound else {
            return nil
        }
        guard status == noErr else {
            return nil
        }
        guard let existingItem = queryResult as? [String: AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
            else {
                return nil
        }
        
        return password
    }
    
    @discardableResult func update(value: String, forKey key: String) -> Bool {
        guard let encodedPassword = value.data(using: String.Encoding.utf8) else {
            return false
        }
        
        var attributesToUpdate = [String: AnyObject]()
        attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?
        let query = KeychainWrapper.queryGenericPassword(withService: key,
                                                           account: key)
        
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
        
        guard status == noErr else {
            return false
        }
        
        return true
    }
    
    @discardableResult func delete(valueForKey key: String) -> Bool {
        let query = KeychainWrapper.queryGenericPassword(withService: key,
                                                           account: key)
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == noErr else {
            return false
        }
        
        return true
    }
    
    @discardableResult func setMnemonic(_ array: [String]) -> Bool {
        do {
            let key = Constants.Main.udMnemonic
            let encodedPassword = try NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: true)
            if getMnemonic() != nil {
                return updateMnemonic(array: array)
            } else {
                var newItem = KeychainWrapper.queryGenericPassword(withService: key,
                                                      account: key)
                newItem[kSecValueData as String] = encodedPassword as AnyObject?

                let status = SecItemAdd(newItem as CFDictionary, nil)
                guard status == noErr else {
                    return false
                }
            }
            
            return true
        } catch {
            print("======Keychain saving array error: \(error)======")
            return false
        }
    }
    
    func getMnemonic() -> [String]? {
        let key = Constants.Main.udMnemonic
        var query = KeychainWrapper.queryGenericPassword(withService: key,
                                                           account: key)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        guard status != errSecItemNotFound else {
            return nil
        }
        guard status == noErr else {
            return nil
        }
        guard let existingItem = queryResult as? [String: AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data else {
                return nil
        }
        
        do {
            let password = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(passwordData) as? [String]
            return password
        } catch {
            print("======Keychain retrieving array error: \(error)======")
            return nil
        }
    }
    
    @discardableResult func updateMnemonic(array: [String]) -> Bool {
        do {
            let key = Constants.Main.udMnemonic
            let encodedPassword = try NSKeyedArchiver.archivedData(withRootObject: array, requiringSecureCoding: true)
            
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?
            let query = KeychainWrapper.queryGenericPassword(withService: key,
                                                               account: key)
            
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            
            guard status == noErr else {
                return false
            }
            
            return true
        } catch {
            print("======Keychain updating array error: \(error)======")
            return false
        }
    }
    
    @discardableResult func deleteMnemonic() -> Bool {
        let key = Constants.Main.udMnemonic
        let query = KeychainWrapper.queryGenericPassword(withService: key,
                                                           account: key)
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == noErr else {
            return false
        }
        
        return true
    }
    
    @discardableResult func clearKeychain() -> Bool {
        guard value(forKey: Constants.Main.udPasscode) == nil || delete(valueForKey: Constants.Main.udPasscode) else {
            return false
        }
        guard value(forKey: Constants.Main.udUsername) == nil || delete(valueForKey: Constants.Main.udUsername) else {
            return false
        }
        guard value(forKey: Constants.Main.udToken) == nil || delete(valueForKey: Constants.Main.udToken) else {
            return false
        }
        guard value(forKey: Constants.Main.udMnemonicString) == nil || delete(valueForKey: Constants.Main.udMnemonicString) else {
            return false
        }
        
        guard getMnemonic() == nil || deleteMnemonic()  else {
            return false
        }
        return true
    }
    
    //=========================================================
    // MARK: - Query helpers
    //=========================================================
    private class func queryGenericPassword(withService service: String,
                                            account: String? = nil) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        
        return query
    }
}

