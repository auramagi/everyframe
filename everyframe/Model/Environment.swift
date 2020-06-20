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

extension EnvironmentValues {
    var window: NSWindow? {
        get {
            self[NSWindowEnvironmentKey.self]
        }
        
        set {
            self[NSWindowEnvironmentKey.self] = newValue
        }
    }
}
