//
//  ProgressScanner.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/20.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

enum ProgressScanner {
    
    private static let separator = CharacterSet(charactersIn: "=")
    
    // scan line format ^([^=]+)=(.+)$
    static func scanSingleLine(string: String) -> (key: String, value: String)? {
        let scanner = Scanner(string: string)
        scanner.charactersToBeSkipped = nil
        guard let key = scanner.scanUpToCharacters(from: separator),
            scanner.scanCharacters(from: separator) != nil,
            !scanner.isAtEnd
            else { return nil }
        
        let value = String(scanner.string[scanner.currentIndex...])
        
        return (key: key, value: value)
    }
    
}
