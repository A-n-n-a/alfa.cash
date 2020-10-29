//
//  ACError.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 05.02.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

public class ACError: Error, Codable {
    var code: Int = 0
    var message: String = ""
    var errmsg: String?
    var error: String?
    
    convenience init(error: Error) {
        self.init()
        
        let errorObject = error as NSError
        self.code = errorObject.code
        self.message = errorObject.localizedDescription
        
    }
    
    convenience init(code: Int? = 0, message: String) {
        self.init()
        
        if let code = code {
            self.code = code
        }
        self.message = message
        
    }
    
    enum CodingKeys: String, CodingKey {
        case code = "errcode"
        case message
        case errmsg
        case error
    }
    
    required convenience public init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let errorCode = try? container.decode(Int.self, forKey: .code) {
            self.code = errorCode
        }
        if let errorMessage = try? container.decode(String.self, forKey: .message) {
            self.message = errorMessage
        }
        error = try? container.decode(String.self, forKey: .error)
    }
}
