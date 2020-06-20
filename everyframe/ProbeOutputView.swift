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
    var probeOutput: [String: Any]?
    
    private let outlineSize = CGSize(width: 420, height: 400)
    
    var body: some View {
        VStack(spacing: 0) {
            probeValues

            Divider()

            HStack {
                Button(action: showInFinder, label: { Text("Show in Finder") })

                Spacer()

                Button(action: open, label: { Text("Open") })
            }

            .padding()
        }
        .frame(width: outlineSize.width)
    }
    
    var probeValues: some View {
        if let probeOutput = probeOutput {
            return AnyView(makeProbeView(output: probeOutput))
        } else {
            return AnyView(Text("ffprobe failed").padding(24))
        }
    }
    
    func makeProbeView(output: Any) -> some View {
        OutlineView(object: output, flattenTopLevelContainer: true)
            .frame(width: outlineSize.width, height: outlineSize.height)
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
