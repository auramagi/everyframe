//
//  Shell.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

func executeShell(path: String, command: String, pipe: Pipe, environment: [String: String] = [:], terminationHandler: @escaping (Process?) -> Void = { _ in }) {
    let shellPath = ProcessInfo().environment["SHELL"]
    let process = Process()
    process.environment = ProcessInfo().environment
        .merging(environment, uniquingKeysWith: { (old, new) in new })
    process.launchPath = shellPath!
    process.arguments = ["-c", "\(path) \(command)"]
    process.terminationHandler = terminationHandler
    process.standardOutput = pipe
    process.launch()
}
