//
//  FFprobe.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

struct FFprobe {
    let file: URL
    
    private let path: String = "/usr/local/bin/ffprobe"
    private var command: String { "$INPUT -hide_banner -show_format -show_error -show_streams -v quiet -print_format json" }
    
    func run() -> Any? {
        let pipe = Pipe()
        executeShell(path: path, command: command, pipe: pipe, environment: ["INPUT": file.path])
        guard let data = try? pipe.fileHandleForReading.readToEnd(),
            let object = try? JSONSerialization.jsonObject(with: data, options: [])
            else { return nil }
        
        return object
    }
}
