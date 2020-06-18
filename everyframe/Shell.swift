//
//  Shell.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

func shell(path: String, command: String) throws -> Data? {
    let shellPath = ProcessInfo().environment["SHELL"]
    let task = Process()
    task.launchPath = shellPath!
    task.arguments = ["-c", "\(path) \(command)"]

    let pipe = Pipe()
    task.standardOutput = pipe
    task.launch()

    return try pipe.fileHandleForReading.readToEnd()
}
