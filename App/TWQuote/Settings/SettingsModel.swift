//
//  SettingsModel.swift
//  TWQuote
//
//  Created by Fernando Bunn on 11/05/2019.
//  Copyright © 2019 Fernando Bunn. All rights reserved.
//

import Foundation

class SettingsModel: NSObject, NSCoding {
    
    public var sourceCurrency = TWCurrency.BRL
    public var targetCurrency = TWCurrency.EUR
    public var amount = 1000
    
    public lazy var availableCurrencies: [String] = {
        return TWCurrency.allCases.map{ $0.rawValue }
    }()

    required init?(coder aDecoder: NSCoder) {
        self.amount = aDecoder.decodeInteger(forKey: "amount")
        let sourceValue = aDecoder.decodeObject(forKey: "sourceCurrency") as! String
        let targetValue = aDecoder.decodeObject(forKey: "targetCurrency") as! String
        
        self.targetCurrency = TWCurrency(rawValue: targetValue) ?? .EUR
        self.sourceCurrency = TWCurrency(rawValue: sourceValue) ?? .BRL
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(amount, forKey: "amount")
        aCoder.encode(sourceCurrency.rawValue, forKey: "sourceCurrency")
        aCoder.encode(targetCurrency.rawValue, forKey: "targetCurrency")
    }
  
    override init() {
        super.init()
    }
    
    public static func restore() -> SettingsModel {
        guard let data = UserDefaults.standard.object(forKey: Constants.strings.userDefaultKey) as? Data else {
            return SettingsModel()
        }
        
        let settings = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? SettingsModel
        return settings ?? SettingsModel()
    }
    
    public func save() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: Constants.strings.userDefaultKey)
        } catch {
            print("Error \(error)")
        }
    }
}

extension FileManager {
    public static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)
        return paths[0]
    }
}

