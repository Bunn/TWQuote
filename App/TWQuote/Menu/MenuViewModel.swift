//
//  MenuViewModel.swift
//  TWQuote
//
//  Created by Fernando Bunn on 06/05/2019.
//  Copyright © 2019 Fernando Bunn. All rights reserved.
//

import Foundation

class MenuViewModel {
    private lazy var numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        return numberFormatter
    }()
    
    
    func fetchQuote(sourceCurrency: TWCurrency, targetCurrency: TWCurrency, amount: Int, completion: @escaping (String?) -> ()) {
        numberFormatter.currencyCode = targetCurrency.rawValue
        TWService().fetchQuote(sourceCurrency: .BRL, targetCurrency: targetCurrency, amount: amount) { (quote) in
            DispatchQueue.main.async {
                guard let quote = quote else {
                    completion(nil)
                    return
                }
                guard let payment = quote.paymentOptions.first else {
                    completion (nil)
                    return
                }
                completion(self.numberFormatter.string(for: payment.targetAmount))
            }
        }
    }
}
