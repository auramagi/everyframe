//
//  FFprobe.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

struct FFprobe {
    
    typealias Output = Any
    
    let file: URL
    
    private let path: String = "/usr/local/bin/ffprobe"
    private var command: String { "$INPUT -hide_banner -show_format -show_error -show_streams -v quiet -print_format json" }
    
    enum ProbeError: Error {
        case decodingError
        case errorResponse(FFprobeError)
        
        var information: String {
            if case let .errorResponse(error) = self {
                return "\(error.string) (Code \(error.code))"
            } else {
                return "ffprobe failed"
            }
        }
    }
    
    private struct ErrorResponse: Decodable {
        let error: FFprobeError
    }
    
    struct FFprobeError: Decodable {
        let code: Int
        let string: String
    }
    
    func run() -> Result<Any, ProbeError> {
        let pipe = Pipe()
        executeShell(path: path, command: command, pipe: pipe, environment: ["INPUT": file.path])
        let data = pipe.fileHandleForReading.readDataToEndOfFile() // readToEnd() crashes with "Symbol not found"
        
        if let response = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
            return .failure(.errorResponse(response.error))
        } else if let object = try? JSONSerialization.jsonObject(with: data, options: []) {
            return .success(object)
        } else {
            return .failure(.decodingError)
        }
    }
    
}
