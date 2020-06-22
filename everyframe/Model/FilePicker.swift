//
//  FilePicker.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/20.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation
import Cocoa

enum FilePicker {
    static func chooseInput(window: NSWindow, didChoose: @escaping (URL) -> Void) {
        let panel = NSOpenPanel()
        panel.title = "Choose input file"
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        
        panel.beginSheetModal(for: window) { response in
            guard response == .OK, let url = panel.url else { return }
            didChoose(url)
        }
    }
    
    static func chooseOutput(window: NSWindow, prompt: URL, didChoose: @escaping (URL) -> Void) {
        let panel = NSSavePanel()
        panel.title = "Choose output file"
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = prompt.lastPathComponent
        panel.directoryURL = prompt.deletingLastPathComponent()
        
        panel.beginSheetModal(for: window) { response in
            guard response == .OK, let url = panel.url else { return }
            didChoose(url)
        }
    }
}
