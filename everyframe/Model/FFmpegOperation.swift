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
    var output: URL
    
    var options: String { "-i $INPUT $OUTPUT" }
    var optionsOverride: String?
    
    init(input: URL) {
        self.input = input
        self.output = FFmpegOperation.outputURL(forInput: input, pathExtension: input.pathExtension)
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
