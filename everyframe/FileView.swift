//
//  FileView.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI

struct FileView: View {
    
    let file: URL
    
    init(file: URL) {
        self.file = file
    }
    
    var body: some View {
        HStack {
            icon
            
            VStack(alignment: .leading) {
                Text(file.lastPathComponent)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .font(.headline)
                
                format
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
        }
    }
    
    var icon: Image {
        let icon = NSWorkspace.shared.icon(forFile: file.path)
        
        return Image(nsImage: icon)
    }
    
    var format: Text? {
        guard let uti = try? NSWorkspace.shared.type(ofFile: file.path),
            let format = UTTypeCopyDescription(uti as CFString)
            else { return nil }
        return Text(format.takeRetainedValue() as String)
    }
    
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        FileView(file: URL(fileURLWithPath: "/Users/m_apurin/Downloads/inlinemark.mov"))
    }
}
