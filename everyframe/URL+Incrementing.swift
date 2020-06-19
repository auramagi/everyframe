//
//  URL+Incrementing.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/19.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

extension URL {
    mutating func icrementIfExists(fileManager: FileManager = .default) {
        let name = deletingPathExtension().lastPathComponent
        var index = 2
        var result = self
        while fileManager.fileExists(atPath: result.path) {
            result.deleteLastPathComponent()
            result.appendPathComponent("\(name) \(index)")
            result.appendPathExtension(pathExtension)
            index += 1
        }
        self = result
    }
}
