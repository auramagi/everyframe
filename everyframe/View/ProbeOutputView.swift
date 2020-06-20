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
    var output: FFprobe.Output
    
    private let outlineSize = CGSize(width: 420, height: 400)
    
    var body: some View {
        VStack(spacing: 0) {
            OutlineView(
                object: output,
                flattenTopLevelContainer: true
            )
                .frame(width: outlineSize.width, height: outlineSize.height)

            Divider()

            HStack {
                Button(action: showInFinder, label: { Text("Show in Finder") })

                Spacer()

                Button(action: open, label: { Text("Open") })
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .frame(width: outlineSize.width)
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
        ProbeOutputView(file: PreviewData.input, output: PreviewData.probeOutput)
    }
}
