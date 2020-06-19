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
    private var command: String { "\(file.path) -hide_banner -show_format -show_error -show_streams -v quiet -print_format json" }
    
    struct Output {
        let string: String
    }
    
    func run() -> Output? {
        guard let data = try? shell(path: path, command: command),
            let string = String(data: data, encoding: .utf8)
        else { return nil }
        
        return Output(string: string)
    }
    
    /*
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
     */
}
/*
extension FFProbe.Output {
    private enum Formatters {
        private static let duration: DateComponentsFormatter = {
            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute, .second]
            formatter.unitsStyle = .abbreviated
            return formatter
        }()
        
        private static let size: ByteCountFormatter = {
            let formatter = ByteCountFormatter()
            formatter.includesActualByteCount = true
            return formatter
        }()
        
        static func formatDuration(_ interval: TimeInterval) -> String {
            return duration.string(from: interval)!
        }
        
        static func formatSize(_ bytes: Int64) -> String {
            return size.string(fromByteCount: bytes)
        }
    }
    
    var formatString: String {
        return format.format_long_name
    }
    
    
    var durationString: String? {
        guard let interval = TimeInterval(format.duration)
            else { return nil }
        
        return Formatters.formatDuration(interval)
    }
    
    var sizeString: String? {
        guard let bytes = Int64(format.size)
            else { return nil }
        
        return Formatters.formatSize(bytes)
    }
}
*/
