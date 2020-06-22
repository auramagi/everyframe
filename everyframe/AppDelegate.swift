//
//  AppDelegate.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private var cascadingPoint: NSPoint?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        openFile(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        subprocesses.values.forEach { $0.terminate() }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if flag {
            return false
        } else {
            openFile(nil)
            return true
        }
    }

    func application(_ sender: NSApplication, openFile filename: String) -> Bool {
        openFile(URL(fileURLWithPath: filename))
        return true
    }
    
    func openFile(_ url: URL?) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        let model = ContentViewModel()
        model.setInput(url)
        if let error = model.error {
            // handle here and prevent new window being shown
            presentErrorAlert(error: error.error)
            return
        }
        
        let contentView = ContentView(model: model)
            .environment(\.window, window)
        
        window.setFrameAutosaveName("Main Window")
        window.contentView = NSHostingView(rootView: contentView)
        window.titleVisibility = .hidden
        
        let controller = NSWindowController(window: window)
        controller.showWindow(nil)
        
        if let lastSpawnPoint = cascadingPoint {
            self.cascadingPoint = controller.window?.cascadeTopLeft(from: lastSpawnPoint)
        } else {
            controller.window?.center()
            cascadingPoint = controller.window?.cascadeTopLeft(from: .zero)
        }
    }
    
    func presentErrorAlert(error: AppError) {
        error.makeNSAlert()
            .runModal()
    }
    
    @objc func newDocument(_ sender: Any?) {
        openFile(nil)
    }
    
}
