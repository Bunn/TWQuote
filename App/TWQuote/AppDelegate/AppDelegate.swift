//
//  AppDelegate.swift
//  TWQuote
//
//  Created by Fernando Bunn on 03/05/2019.
//  Copyright © 2019 Fernando Bunn. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    let menu = Menu()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApplication.shared.setActivationPolicy(.accessory)
        menu.setupMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

