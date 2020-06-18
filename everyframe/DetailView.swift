//
//  DetailView.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI
import Quartz
import AVFoundation
import AVKit

struct DetailView: View {
    
    let file: URL
    let probeOutput: FFProbe.Output?
    
    init(file: URL) {
        self.file = file
        let probe = FFProbe(file: file)
        self.probeOutput = probe.run()
    }
    
    var body: some View {
        VStack {
            Form {
                Section {
                    HStack {
                        icon
                        
                        VStack(alignment: .leading) {
                            Text(file.lastPathComponent)
                                .lineLimit(1)
                                .truncationMode(.middle)
                                .font(.headline)

//                            format
                            
                            format2
                                .lineLimit(1)
                                .truncationMode(.middle)
                        }
                    }
                }
                
                Divider()
                    .padding(.horizontal, -16)
                
                Section(
                    header: Text("Information")
                        .font(.subheadline)
                ) {
                    HStack {
                        Text("Duration")
                            .font(.caption)
                            .foregroundColor(Color(NSColor.secondaryLabelColor))
                        
                        Spacer()
                        
                        duration
                    }
                    
                    HStack {
                        Text("Size")
                            .font(.caption)
                            .foregroundColor(Color(NSColor.secondaryLabelColor))
                        
                        Spacer()
                        
                        size
                    }
                }
                .padding(.bottom, 6)
            }.padding(16)
            
        }
    }
    
    var icon: Image {
        let icon = NSWorkspace.shared.icon(forFile: file.path)
        
        return Image(nsImage: icon)
    }
    
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
    
    var format: Text? {
        guard let format = probeOutput?.format.format_long_name else { return nil }
        return Text(format)
    }
    
    var format2: Text? {
        guard let uti = try? NSWorkspace.shared.type(ofFile: file.path),
            let format = UTTypeCopyDescription(uti as CFString)
            else { return nil }
        return Text(format.takeRetainedValue() as String)
    }
    
    var duration: Text? {
        guard let duration = probeOutput?.format.duration,
            let interval = TimeInterval(duration)
        else { return nil }
        
        return Text(Formatters.formatDuration(interval))
    }
    
    var size: Text? {
        guard let size = probeOutput?.format.size,
            let bytes = Int64(size)
            else { return nil }
        
        let text = Formatters.formatSize(bytes)
        return Text(text)
    }
    
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(file: URL(fileURLWithPath: "/Users/m_apurin/Downloads/inlinemark.mov"))
    }
}
