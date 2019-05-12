//
//  SettingsViewController.swift
//  TWQuote
//
//  Created by Fernando Bunn on 11/05/2019.
//  Copyright © 2019 Fernando Bunn. All rights reserved.
//

import Cocoa

class OnlyIntegerValueFormatter: NumberFormatter {
    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if partialString.isEmpty {
            return true
        }
        return Int(partialString) != nil
    }
}

class SettingsViewController: NSViewController {
    public weak var delegate: SettingsViewControllerDelegate?
    private let settingsModel = SettingsModel.restore()
    @IBOutlet private weak var sourceCurrencyComboBox: NSComboBox!
    @IBOutlet private weak var targetCurrencyComboBox: NSComboBox!
    @IBOutlet private weak var valueTextField: NSTextField!

    override func viewDidLoad() {
        title = UIConstants.strings.settingsWindowTitle
        
        sourceCurrencyComboBox.addItems(withObjectValues: settingsModel.availableCurrencies)
        sourceCurrencyComboBox.selectItem(withObjectValue: settingsModel.sourceCurrency.rawValue)

        targetCurrencyComboBox.addItems(withObjectValues: settingsModel.availableCurrencies)
        targetCurrencyComboBox.selectItem(withObjectValue: settingsModel.targetCurrency.rawValue)
        valueTextField.formatter = OnlyIntegerValueFormatter()
        valueTextField.stringValue = String(settingsModel.amount)
    }
    
    override func viewDidAppear() {
        view.window!.styleMask.remove(.resizable)
    }
    
    @IBAction private func saveButtonClicked(_ sender: Any) {
        let sourceCurrencyValue = settingsModel.availableCurrencies[sourceCurrencyComboBox.indexOfSelectedItem]
        let targetCurrencyValue = settingsModel.availableCurrencies[targetCurrencyComboBox.indexOfSelectedItem]
        
        guard let targetCurrency = TWCurrency(rawValue: targetCurrencyValue) else { return }
        guard let sourceCurrency = TWCurrency(rawValue: sourceCurrencyValue) else { return }
        guard let amount = Int(valueTextField.stringValue) else { return }
        
        settingsModel.targetCurrency = targetCurrency
        settingsModel.sourceCurrency = sourceCurrency
        settingsModel.amount = amount
        
        settingsModel.save()
        delegate?.didSave(controller: self)
    }
}

protocol SettingsViewControllerDelegate: class {
    func didSave(controller: SettingsViewController)
}
