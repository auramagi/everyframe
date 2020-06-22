//
//  ControlSize+AppKit.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/22.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI
import AppKit

extension ControlSize {
    var nsControlControlSize: NSControl.ControlSize {
        switch self {
        case .regular:
            return .regular
            
        case .small:
            return .small
            
        case .mini:
            return .mini
            
        @unknown default:
            return .regular
        }
    }
}
