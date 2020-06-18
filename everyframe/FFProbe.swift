//
//  FFProbe.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import Foundation

struct FFProbe {
    let file: URL
    
    private let path: String = "/usr/local/bin/ffprobe"
    private var command: String { "\(file.path) -hide_banner -show_format -v quiet -print_format json" }
    
    struct Output: Codable {
        
        struct Format: Codable {
            let format_long_name: String
            let start_time: String
            let duration: String
            let size: String
        }
        
        let format: Format
        
    }
    
    func run() -> Output? {
        guard let data = try? shell(path: path, command: command),
            let output = try? JSONDecoder().decode(Output.self, from: data)
            else { return nil }
        return output
    }
}
