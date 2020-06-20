//
//  Shell.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

var subprocesses: [UUID: Process] = [:]

@discardableResult
func executeShell(path: String, command: String, pipe: Pipe, environment: [String: String] = [:], terminationHandler: @escaping (Process?) -> Void = { _ in }) -> Process {
    let uuid = UUID()
    let shellPath = ProcessInfo().environment["SHELL"]
    let process = Process()
    subprocesses[uuid] = process
    
    process.environment = ProcessInfo().environment
        .merging(environment, uniquingKeysWith: { (old, new) in new })
    process.launchPath = shellPath!
    process.arguments = ["-c", "\(path) \(command)"]
    process.terminationHandler = {
        subprocesses.removeValue(forKey: uuid)
        terminationHandler($0)
    }
    process.standardOutput = pipe
    
    process.launch()
    
    return process
}
