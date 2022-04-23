//
//  TWService.swift
//  TWQuote
//
//  Created by Fernando Bunn on 03/05/2019.
//  Copyright © 2019 Fernando Bunn. All rights reserved.
//

import Foundation

struct TWResponse: Codable {
    let providers: [Provider]
    var wiseQuote: Quote? {
        guard let wise = providers.filter({ $0.alias == "wise" }).first else { return nil }
        return wise.quotes.first
    }
}

struct Provider: Codable {
    let id: Int
    let alias: String
    let name: String
    let quotes: [Quote]
}

struct Quote: Codable {
    let rate: Decimal
    let fee: Decimal
    let receivedAmount: Decimal
}

enum TWCurrency: String, CaseIterable {
    case BRL = "BRL"
    case EUR = "EUR"
    case USD = "USD"
    case GBP = "GBP"
}

struct TWService {
    let urlPah = "https://wise.com/gateway/v3/comparisons"

    func fetchQuote(sourceCurrency: TWCurrency, targetCurrency: TWCurrency, amount: Int, completion: @escaping (TWResponse?) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        guard var URL = URL(string: urlPah) else {
            completion(nil)
            return
        }
        
        let URLParams = [
            "sendAmount": String(amount),
            "sourceCurrency": sourceCurrency.rawValue,
            "targetCurrency": targetCurrency.rawValue,
        ]
        URL = URL.appendingQueryParameters(URLParams)
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        

        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if (error == nil) {
                if let data = data {
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let twResponse = try decoder.decode(TWResponse.self, from: data)
                        completion(twResponse)
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
