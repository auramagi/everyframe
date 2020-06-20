//
//  ProgressView.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/20.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI

struct ProgressView: View {
    
    let progress: [String: String]
    
    var body: some View {
        Form {
            Section {
                makeRow(title: "Duration", content: Text(duration))
                
                makeRow(title: "Size", content: Text(size))
                
                makeRow(title: "Speed", content: Text(speed))
                
                makeRow(title: "Bitrate", content: Text(bitrate))
                
                Divider()
                
                makeRow(title: "Frame", content: Text(frame))
            }
        }
        .padding()
    }
    
    func makeRow(title: String, content: Text?) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(Color(NSColor.secondaryLabelColor))
            
            Spacer()
            
            content?
                .multilineTextAlignment(.trailing)
        }
    }
    
    private static let durationFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        return formatter
    }()
    
    private static let sizeFormatter: ByteCountFormatter = {
        let formatter = ByteCountFormatter()
        return formatter
    }()
    
    var duration: String {
        let ms = Int(progress["out_time_ms"] ?? "0") ?? 0
        let interval = TimeInterval(ms) / 1000000
        return ProgressView.durationFormatter.string(from: interval)!
        
    }
    
    var size: String {
        let byteCount = Int64(progress["total_size"] ?? "0") ?? 0
        return ProgressView.sizeFormatter.string(fromByteCount: byteCount)
    }
    
    var speed: String {
        progress["speed"] ?? "0x"
    }
    
    var bitrate: String {
        progress["bitrate"]  ?? "0 kbits/s"
    }
    
    var frame: String {
        progress["frame"] ?? "0"
    }
    
}

struct ProgressView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressView(progress: [
            "out_time_ms": "420000",
            "total_size": "148754",
            "speed": "0.389x",
            "bitrate": "166.9kbits/s"
        ])
    }
}
