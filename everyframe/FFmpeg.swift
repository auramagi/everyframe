//
//  FFmpeg.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/19.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

struct FFmpeg {
    let operation: FFmpegOperation
    
    private let path: String = "/usr/local/bin/ffmpeg"
    private var command: String {
        let options = operation.optionsOverride ?? operation.options
        return "-y -progress - -v level+error \(options)"
    }
    
    func run() {
        let pipe = Pipe()
        
        let handler =  { (file: FileHandle!) -> Void in
            let data = file.availableData
            guard let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                else { return }
            print("*** NEW DATA ***")
            print(output)
        }
        
        pipe.fileHandleForReading.readabilityHandler = handler
        
        executeShell(
            path: path,
            command: command,
            pipe: pipe,
            environment: ["INPUT": operation.input.path, "OUTPUT": operation.output.path],
            terminationHandler: { _ in pipe.fileHandleForReading.readabilityHandler = nil }
        )
        
    }
    
}
