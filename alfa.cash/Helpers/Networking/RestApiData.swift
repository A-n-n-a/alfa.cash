//
//  RestApiData.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 22.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import Foundation

struct RestApiData {
    var url: String
    var httpMethod: HttpMethod
    var headers: [String: String]?
    var parameters: [String: Any]
    var keyPath: String?
    var customTimeoutInterval: TimeInterval?
    var postData: Data?
    
    init(url: String,
         httpMethod: HttpMethod,
         headers: [String: String]? = nil,
         parameters: ParametersProtocol? = nil,
         keyPath: String? = nil,
         postData: Data? = nil) {
        self.url = url
        self.httpMethod = httpMethod
        self.headers = headers
        self.keyPath = keyPath
        self.parameters = parameters?.dictionaryValue ?? [:]
        self.postData = postData
    }
}

extension RestApiData {
    var urlWithParametersString: String {
        var parametersString = ""
        for (offset: index, element: (key: key, value: value)) in parameters.enumerated() {
            parametersString += "\(key)=\(value)"
            if index < parameters.count - 1 {
                parametersString += "&"
            }
        }
        parametersString = parametersString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        if !parametersString.isEmpty {
            parametersString = "?" + parametersString
        }
        return url + parametersString
    }
}

