//
//  FFmpegOperation.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/19.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

struct FFmpegOperation {
    let input: URL
    let inputProbe: FFprobe.Output
    var output: URL
    
    var options: String { "-i $INPUT $OUTPUT" }
    var optionsOverride: String?
    
    init(input: URL, inputProbe: FFprobe.Output) {
        self.input = input
        self.inputProbe = inputProbe
        self.output = FFmpegOperation.outputURL(forInput: input, pathExtension: input.pathExtension)
    }
    
    static func make(input: URL) -> Result<FFmpegOperation, AppError> {
        FFprobe(file: input)
            .run()
            .map { FFmpegOperation(input: input, inputProbe: $0) }
            .mapError { $0.toAppError() }
    }
    
    static func outputURL(forInput url: URL, pathExtension: String) -> URL {
        var output = url
        output.deletePathExtension()
        let name = "\(output.lastPathComponent)_output"
        output.deleteLastPathComponent()
        output.appendPathComponent(name)
        output.appendPathExtension(pathExtension)
        output.icrementIfExists()
        return output
    }
}
