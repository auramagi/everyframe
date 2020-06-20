//
//  FileView.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI

struct FileViewModel {
    let icon: NSImage
    let title: String
    let subtitle: String
    
    init(inputFile: URL) {
        self.icon = NSWorkspace.shared.icon(forFile: inputFile.path)
        self.title = inputFile.lastPathComponent
        self.subtitle = FileViewModel.makeFormatText(file: inputFile)
            ?? inputFile.deletingLastPathComponent().path
    }
    
    init(outputFile: URL) {
        self.icon = NSWorkspace.shared.icon(forFileType: outputFile.pathExtension)
        self.title = outputFile.lastPathComponent
        self.subtitle = outputFile.deletingLastPathComponent().path
    }
    
    private static func makeFormatText(file: URL) -> String? {
        guard let uti = try? NSWorkspace.shared.type(ofFile: file.path),
            let format = UTTypeCopyDescription(uti as CFString)
            else { return nil }
        
        return format.takeRetainedValue() as String
    }
}

struct FileView: View {
    
    let model: FileViewModel
    
    var body: some View {
        HStack {
            Image(nsImage: model.icon)
            
            VStack(alignment: .leading) {
                Text(model.title)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .font(.headline)
                
                Text(model.subtitle)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }
    
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            FileView(model: FileViewModel(inputFile: PreviewData.input))
            
            FileView(model: FileViewModel(outputFile: PreviewData.output))
        }
    }
}
