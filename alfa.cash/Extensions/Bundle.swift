//
//  Bundle.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 20.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

private var kBundleKey: UInt8 = 0

class BundleEx: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &kBundleKey) as? Bundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }
        
        return super.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    static let once: Void = {
        object_setClass(Bundle.main, type(of: BundleEx()))
    }()
    
    class func setLanguage(_ language: String) {
        Bundle.once
        guard let path = Bundle.main.path(forResource: language, ofType: "lproj") else {
            return
        }
        
        let value = Bundle(path: path)
        objc_setAssociatedObject(Bundle.main, &kBundleKey, value,
                                 objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    var version: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var build: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

