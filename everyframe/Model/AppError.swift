//
//  AppError.swift
//  everyframe
//
//  Created by Mikhail Apurin on 21.06.2020.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation
import AppKit
import SwiftUI

struct AppError: Error {
    let message: String
    let information: String
    let underlying: Error?
    
    func makeNSAlert() -> NSAlert {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = information
        return alert
    }
    
    func makeAlert() -> Alert {
        Alert(
            title: Text(message),
            message: Text(information),
            dismissButton: .default(Text("OK"))
        )
    }
}

struct IdentifiableAppError: Identifiable {
    let id = UUID()
    let error: AppError
}
