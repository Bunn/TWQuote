//
//  Menu.swift
//  TWQuote
//
//  Created by Fernando Bunn on 03/05/2019.
//  Copyright © 2019 Fernando Bunn. All rights reserved.
//

import Foundation
import AppKit

class Menu {
    private let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private var windowController: NSWindowController?
    private var progressIndicator = NSProgressIndicator()
    private var callTimer: Timer?
    private let viewModel = MenuViewModel()
    private let autoRefreshTimeInterval : TimeInterval = 60 * 5

    
    public func setupMenu() {
        let menu = NSMenu()
        
        let refreshMenuItem = NSMenuItem(title: UIConstants.strings.menuRefreshButton, action: #selector(Menu.refresh), keyEquivalent: "")
        refreshMenuItem.target = self
        menu.addItem(refreshMenuItem)

        let settingsMenuItem = NSMenuItem(title: UIConstants.strings.menuSettingsLabel, action: #selector(Menu.openSettings), keyEquivalent: "")
        settingsMenuItem.target = self
        menu.addItem(settingsMenuItem)

        let quitMenuItem = NSMenuItem(title: UIConstants.strings.menuQuitButton, action: #selector(Menu.quit), keyEquivalent: "")
        quitMenuItem.target = self
        menu.addItem(quitMenuItem)
        
        item.menu = menu
        progressIndicator.style = .spinning
        callTimer = Timer.scheduledTimer(timeInterval: autoRefreshTimeInterval, target: self, selector: #selector(updateData), userInfo: nil, repeats: true)

        updateData()
    }
    
    private func displaySpinner(display: Bool) {
        guard let button = self.item.button else { return }
        
        button.title = ""
        
        progressIndicator.frame = button.frame
        if display {
            self.item.button?.addSubview(progressIndicator)
            progressIndicator.startAnimation(self)
        } else {
            progressIndicator.removeFromSuperview()
            progressIndicator.stopAnimation(self)
        }
    }
    
    @objc private func updateData() {
        displaySpinner(display: true)
        
        viewModel.fetchQuote { (value) in
            self.displaySpinner(display: false)
            if let value = value {
                self.item.button?.title = value
            } else {
                self.item.button?.title = UIConstants.strings.menuErrorLabel
            }
        }
    }
    
    
    //MARK: - Button Methods
    
    @objc private func openSettings() {
        NSApp.activate(ignoringOtherApps: true)
        let settings = SettingsViewController()
        settings.delegate = self
        if windowController == nil {
            let window = NSWindow(contentViewController: settings)
            windowController = NSWindowController(window: window)
        }
        windowController?.showWindow(self)
        windowController?.window?.makeKey()
    }
    
    @objc private func refresh() {
        updateData()
    }
    
    @objc private func quit() {
        NSApplication.shared.terminate(self)
    }
}


extension Menu: SettingsViewControllerDelegate {
    
    func didSave(controller: SettingsViewController) {
        windowController?.close()
        updateData()
    }
}
