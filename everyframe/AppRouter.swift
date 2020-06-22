//
//  AppRouter.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/22.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation
import Cocoa
import SwiftUI

class AppRouter: NSResponder {
    
    private var cascadingPoint: NSPoint?
        
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
        
        controller.nextResponder = self
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
    
    @IBAction func openPreferences(_ sender: Any?) {
        print("open pref")
    }
    
}
