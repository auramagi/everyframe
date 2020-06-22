//
//  AppDelegate.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private let router: AppRouter = .init()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let application = aNotification.object as? NSApplication
        application?.nextResponder = router
        router.openFile(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        subprocesses.values.forEach { $0.terminate() }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        } else {
            router.openFile(nil)
            return true
        }
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        let input = URL(fileURLWithPath: filename)
        router.openFile(input)
        return true
    }
    
}
