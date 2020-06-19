//
//  ContentView.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI

struct ContentView: View, DropDelegate {
    
    let window: NSWindow
    
    @State var openedFile: URL?
    @State var dropState: DropState = .uninitiated
    @State var showingProbeOutput: Bool = false
    
    enum DropState {
        case uninitiated
        case possible
        case forbidden
    }
    
    var body : some View {
        fileView
            .frame(minWidth: 320, idealWidth: 640, maxWidth: .infinity, minHeight: 240, idealHeight: 480, maxHeight: .infinity, alignment: .center)
            .onDrop(of: [(kUTTypeFileURL as String)], delegate: self)
    }
    
    var fileView: some View {
        switch dropState {
        case .uninitiated:
            if let openedFile = openedFile {
                return AnyView(
                    Form {
                        Section() {
                            Button(action: openFile) {
                                HStack {
                                    FileView(file: openedFile)
                                    
                                    Spacer()
                                    
                                    Button(
                                        action: { self.showingProbeOutput = true },
                                        label: { Text("􀅴").font(.system(size: 18)) }
                                    )
                                        .buttonStyle(LinkButtonStyle())
                                        .popover(
                                            isPresented:  $showingProbeOutput,
                                            content: { self.probeOutput }
                                    )
                                    
                                }
                            }
                        .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                        
                        Divider()
                        
                        Spacer().frame(minWidth: 200)
                    }
                    .padding(.vertical)
                )
            } else {
                return AnyView(
                    VStack {
                        Button(
                            action: { DispatchQueue.main.async(execute: self.openFile) },
                            label: { Text("Choose input") }
                        )
                    }
                )
            }
            
        case .possible:
            return AnyView(Text("Drop here"))
            
        case .forbidden:
            return AnyView(Text("Don't drop here"))
            
        }
    }
    
    var probeOutput: ProbeOutputView? {
        guard let file = openedFile else { return nil }
        return ProbeOutputView(file: file, probeOutput: FFProbe(file: file).run())
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        if info.hasItemsConforming(to: [kUTTypeFileURL as String]) {
            dropState = .possible
            return DropProposal(operation: .copy)
        } else {
            dropState = .forbidden
            return DropProposal(operation: .forbidden)
        }
    }
    
    func dropEntered(info: DropInfo) {
        dropState = .possible
    }
    
    func dropExited(info: DropInfo) {
        dropState = .uninitiated
    }
    
    func performDrop(info: DropInfo) -> Bool {
        guard let itemProvider = info.itemProviders(for: [(kUTTypeFileURL as String)]).first else { return false }
        
        itemProvider.loadItem(forTypeIdentifier: (kUTTypeFileURL as String), options: nil) {item, error in
            guard let data = item as? Data, let url = URL(dataRepresentation: data, relativeTo: nil) else { return }
            DispatchQueue.main.async {
                self.openedFile = url
            }
        }
        
        return true
    }
    
    func openFile() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.title = "Choose input file"
        
        
        panel.beginSheetModal(for: window) { response in
            if response == .OK { self.openedFile = panel.url }
            panel.close()
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(window: .init())
            
            ContentView(window: .init(), openedFile: URL(fileURLWithPath: "/Users/m_apurin/Downloads/inlinemark.mov"))
            
        }
    }
}
