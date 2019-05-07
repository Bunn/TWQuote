//
//  TWService.swift
//  TWQuote
//
//  Created by Fernando Bunn on 03/05/2019.
//  Copyright © 2019 Fernando Bunn. All rights reserved.
//

import Foundation

struct TWQuote: Codable {
    let paymentOptions: [PaymentOption]
}

struct PaymentOption: Codable {
    let targetAmount: Decimal
}

enum TWCurrency: String {
    case BRL = "BRL"
    case EUR = "EUR"
    case USD = "USD"
    case GBP = "GBP"
}


struct TWService {
    let authorizationHeaderValue = "dad99d7d8e52c2c8aaf9fda788d8acdc"
    let authorizationHeaderKey = "X-Authorization-key"
    let urlPah = "https://transferwise.com/api/v1/payment/legacyQuote"
    
    func fetchQuote(sourceCurrency: TWCurrency, targetCurrency: TWCurrency, amount: Int, completion: @escaping (TWQuote?) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard var URL = URL(string: urlPah) else {
            completion(nil)
            return
        }
        
        let URLParams = [
            "amount": String(amount),
            "amountCurrency": "source",
            "getNoticeMessages": "true",
            "hasDiscount": "false",
            "isFixedRate": "false",
            "isGuaranteedFixedTarget": "false",
            "payInMethod": "REGULAR",
            "sourceCurrency": sourceCurrency.rawValue,
            "targetCurrency": targetCurrency.rawValue,
        ]
        URL = URL.appendingQueryParameters(URLParams)
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        
        // Headers
        request.addValue(authorizationHeaderValue, forHTTPHeaderField: authorizationHeaderKey)
        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let quote = try decoder.decode(TWQuote.self, from: data)
                        completion(quote);
                    } catch {
                        print("Error \(error)")
                        completion(nil)
                    }
                }
            }
            else {
                print("URL Session Task Failed: %@", error!.localizedDescription);
                completion(nil)
            }
        })
        task.resume()
        session.finishTasksAndInvalidate()
    }
}

protocol URLQueryParameterStringConvertible {
    var queryParameters: String { get }
}

extension Dictionary : URLQueryParameterStringConvertible {
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
}

extension URL {
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}
