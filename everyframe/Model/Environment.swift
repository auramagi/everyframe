//
//  Environment.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/20.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI

struct NSWindowEnvironmentKey: EnvironmentKey {
    static var defaultValue: NSWindow? = nil
}

struct WindowTitleEnvironmentKey: EnvironmentKey {
    static var defaultValue: String = ""
}

extension EnvironmentValues {
    var window: NSWindow? {
        get {
            self[NSWindowEnvironmentKey.self]
        }
        
        set {
            self[NSWindowEnvironmentKey.self] = newValue
            newValue?.title = self[WindowTitleEnvironmentKey.self]
        }
    }
    
    var windowTitle: String {
        get {
            self[WindowTitleEnvironmentKey.self]
        }
        
        set {
            self[WindowTitleEnvironmentKey.self] = newValue
            self[NSWindowEnvironmentKey.self]?.title = newValue
        }
    }
}
