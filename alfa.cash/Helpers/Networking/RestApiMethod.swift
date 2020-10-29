//
//  RestApiMethod.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 22.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

protocol RestApiMethod {
    var data: RestApiData { get }
}

/// HttpMethod
public enum HttpMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

extension RestApiMethod {
    var url: String {
        
        return Endpoints.baseURL
    }
}

extension RestApiMethod {
    static func ==(lhs: RestApiMethod, rhs: RestApiMethod) -> Bool {
        if let left = lhs as? TemplatesAPIRequest,
            let right = rhs as? TemplatesAPIRequest {
            return left.url == right.url
        }
        return false
    }
}

