//
//  PreviewData.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/19.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

enum PreviewData {
    static var input: URL { Bundle.main.url(forResource: "test", withExtension: "mov")! }
    static var output: URL {
        let url = try! FileManager.default.url(
            for: .downloadsDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
        return url.appendingPathComponent("output").appendingPathExtension("mov")
    }
}
