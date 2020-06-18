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
            VStack {
                QuickLookPreview(file: file)
                    .padding(.top)
                    .padding()
            }.background(Color.black)
            Form {
                Section {
                    VStack {
                        Text(file.path)
                        
                        format
                        
                        HStack {
                            duration
                            
                            Divider()
                                .frame(height: 8)
                            
                            size
                        }
                    }.padding()
                }
            }
            
        }
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


struct VideoPlayer: NSViewRepresentable {
    let item: AVPlayerItem
    
    init(file: URL) {
        self.item = AVPlayerItem(url: file)
    }
    
    func makeNSView(context: Context) -> AVPlayerView {
        let nsView = AVPlayerView()
        nsView.player = AVPlayer()
        return nsView
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        if nsView.player?.currentItem != item {
            nsView.player?.replaceCurrentItem(with: item)
            nsView.player?.play()
        }
    }
}


struct QuickLookPreview: NSViewRepresentable {
    let file: URL
    
    func makeNSView(context: Context) -> QLPreviewView {
        let nsView = QLPreviewView(frame: .zero, style: .normal)!
        return nsView
    }
    
    func updateNSView(_ nsView: QLPreviewView, context: Context) {
        nsView.previewItem = file as NSURL
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(file: URL(fileURLWithPath: "/Users/m_apurin/Downloads/inlinemark.mov"))
    }
}
