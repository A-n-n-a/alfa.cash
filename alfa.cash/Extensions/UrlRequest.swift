//
//  UrlRequest.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 22.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

extension URLRequest {
    
    mutating func addHttpBody(parameters: [String: Any]) {
        do {
            let jsonObject = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            httpBody = jsonObject
        } catch let error {
            #if DEBUG
            print(error)
            #endif
        }
    }
    
    mutating func addHeaders(_ headers: [String: String]?) {
        var headers: [String: String] = headers ?? [:]
        headers["Content-Type"] = "application/json"
        
        if let token = KeychainWrapper.standart.value(forKey: Constants.Main.udToken) {
            #if DEBUG
            print("TOKEN: ", token)
            #endif
            headers["x-auth-token"] = token
        }
        
        print("HEADERS:\n\t\(headers)")
        
        for (headerField, value) in headers {
            setValue(value, forHTTPHeaderField: headerField)
        }
    }
    
}
