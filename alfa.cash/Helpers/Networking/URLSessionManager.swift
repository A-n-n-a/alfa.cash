//
//  URLSessionManager.swift
//  AlfaCash
//
//  Created by Anna Alimanova on 22.01.2020.
//  Copyright © 2020 Anna Alimanova. All rights reserved.
//

import UIKit

class URLSessionRestApiManager {
    
    private static let session = URLSession(configuration: .default, delegate: nil, delegateQueue: nil)
    
    static func call<T: Decodable>(method: RestApiMethod, completion: @escaping (_ result: Result<T>) -> Void) {
        guard let request = URLSessionRestApiManager.request(method: method) else {
            return
        }
        
        let dataTask = URLSessionRestApiManager.session.dataTask(with: request) { (data, urlResponse, error) in
            if let data = data {
                #if DEBUG
                print("\n\n-------------------------------------------------------------")
                if let response = urlResponse as? HTTPURLResponse {
                    #if DEBUG
                    print("STATUS CODE: ", response.statusCode)
                    #endif
                    if response.statusCode == 401 { //token dead
                        let error = ACError(code: 401, message: "Token is dead")
                        completion(.failure(error))
                        return
                    }
                }
                #if DEBUG
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String : AnyObject] {
                    print("RESPONSE JSON:\n\t",json)
                }
//                print("RESPONSE:\n\t\(String(describing: String(data: data, encoding: .utf8)))")
                print("METHOD:\n\t\(method)")
                #endif
                print("\n\n-------------------------------------------------------------")
                #endif
                do {
                    let object = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(object))
                } catch let error {
                    print(error)
                    print((error as! NSError).code)
                    error.localizedDescription
                    var acError = ACError(error: error)
                    if let err = try? JSONDecoder().decode(ACError.self, from: data) {
                        acError = err
                    } else {
                        acError = ACError(message: "AN_UNEXPECTED_ERROR".localized())
                    }
                    if let error = error as? DecodingError {
                        switch error {
                        case let .typeMismatch(type, context):
                            ACLogger.log("Type mismatch. Type - \(type), context - \(context.codingPath)")

                        case let .valueNotFound(value, context):
                            ACLogger.log("Value mismatch. Value - \(value), context - \(context.codingPath)")
                        case let .keyNotFound(key, context):
                            ACLogger.log("Key mismatch. Key - \(key.stringValue), context - \(context.codingPath)")
                        case let .dataCorrupted(context):
                            ACLogger.log("Data corrupted. Context - \(context.debugDescription)")
                        default:
                            break
                        }
                    }
                    completion(.failure(acError))
                }
            }
            
            if let error = error {
                let acError = ACError(error: error)
                completion(.failure(acError))
            }
            
            // Print response
            #if DEBUG
            URLSessionRestApiManager.printDataResponse(urlResponse, request: request, data: data)
            #endif
        }
        dataTask.resume()
    }
}

// MARK: - Request
extension URLSessionRestApiManager {
    private static func request(method: RestApiMethod) -> URLRequest? {
        var hashtagUrl: URL?
        if let hashtags = method.data.parameters["hashtag"] as? [String] {
            var queryItems = [URLQueryItem]()
            for tag in hashtags {
                let item = URLQueryItem(name: "hashtag", value: tag)
                queryItems.append(item)
            }
            if let urlComps = NSURLComponents(string: Endpoints.baseURL) {
                urlComps.queryItems = queryItems
                hashtagUrl = urlComps.url
            }
        }
        let urlString = method.data.httpMethod == .get ? method.data.urlWithParametersString : method.data.url
        
        guard let url = hashtagUrl ?? URL(string: urlString) else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.timeoutInterval = method.data.customTimeoutInterval ?? 30.0
        urlRequest.httpMethod = method.data.httpMethod.rawValue
        urlRequest.addHeaders(method.data.headers)
        if method.data.httpMethod != .get {
            if let postData = method.data.postData {
                print(String(data: postData, encoding: .utf8)!)
                urlRequest.httpBody = postData
            } else {
                urlRequest.addHttpBody(parameters: method.data.parameters)
            }
        }
        return urlRequest
    }
}

extension URLSessionRestApiManager {
    private static func printDataResponse(_ dataResponse: URLResponse?, request: URLRequest, data: Data?) {
        var printResponse = false
        
        print("\n\n---------------------------------------------------")
        defer {
            print("---------------------------------------------------\n\n")
        }
        
        if let httpBody = request.httpBody {
            if let parameters = String(data: httpBody, encoding: .utf8),
                (parameters.range(of: "p22") != nil || parameters.range(of: "p21") != nil ||
                    parameters.range(of: "p62") != nil || parameters.range(of: "p34") != nil ||
                    parameters.range(of: "p69") != nil) {
                printResponse = false
            }
        }
        
        #if DEBUG
        print("REQUEST:\n\t\(request)")
        #endif
        if let httpBody = request.httpBody {
            if let parameters = String(data: httpBody, encoding: .utf8) {
                #if DEBUG
                print("\tparameters: \(parameters)")
                #endif
            }
        }
        do {
            if let data = data, printResponse {
                #if DEBUG
                print("RESPONSE:\n\(try JSONSerialization.jsonObject(with: data, options: .allowFragments))")
                #endif
            }
        } catch {}
    }
}

