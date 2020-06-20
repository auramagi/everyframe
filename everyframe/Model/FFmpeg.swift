//
//  FFmpeg.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/19.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation
import Combine

struct FFmpeg {
    let operation: FFmpegOperation
    
    private let path: String = "/usr/local/bin/ffmpeg"
    private var command: String {
        let options = operation.optionsOverride ?? operation.options
        return "-y -progress - -v level+info -nostats -hide_banner \(options)"
    }
    
    enum ExecutionStatus {
        case started
        case completed
    }
    
    func run() -> AnyPublisher<[String: String], Never> {
        let pipe = Pipe()
        let subject: PassthroughSubject<[String: String], Never> = PassthroughSubject()
        
        let updateHandler =  { (file: FileHandle!) in
            let data = file.availableData
            guard let output = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
                else { return }
            
            var progress: [String: String] = [:]
            output.enumerateLines { line, _ in
                guard line.first != "[",
                    let (key, value) = ProgressScanner.scanSingleLine(string: line)
                    else { return }
                
                progress[key] = value
            }
            subject.send(progress)
        }
        
        let terminationHandler = { (process: Process?) in
            pipe.fileHandleForReading.readabilityHandler = nil
            subject.send(completion: .finished)
        }
        
        pipe.fileHandleForReading.readabilityHandler = updateHandler
        
        executeShell(
            path: path,
            command: command,
            pipe: pipe,
            environment: ["INPUT": operation.input.path, "OUTPUT": operation.output.path],
            terminationHandler: terminationHandler
        )
        
        return subject.eraseToAnyPublisher()
    }
    
}
