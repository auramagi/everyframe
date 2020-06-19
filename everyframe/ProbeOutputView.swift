//
//  ProbeOutputView.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/19.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI

struct ProbeOutputView: View {
    
    var file: URL
    var probeOutput: FFprobe.Output?
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                Text(probeOutput?.string ?? "ffprobe failed")
            }
            
            Divider()
            
            HStack {
                Button(action: showInFinder, label: { Text("Show in Finder") })
                
                Spacer()
                
                Button(action: open, label: { Text("Open") })
            }

            .padding()
        }
        .frame(minWidth: 240, maxWidth: 240, maxHeight: 400)
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
    
    func showInFinder() {
        NSWorkspace.shared.selectFile(file.path, inFileViewerRootedAtPath: "")
    }
    
    func open() {
        NSWorkspace.shared.openFile(file.path, withApplication: nil, andDeactivate: true)
    }
    
}

struct ProbeOutputView_Previews: PreviewProvider {
    static var previews: some View {
        ProbeOutputView(file: PreviewData.input)
    }
}
