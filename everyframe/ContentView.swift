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
    
    @State var operation: FFmpegOperation? = .init(input: PreviewData.input)
    @State var dropState: DropState = .uninitiated
    @State var showingProbeOutput: Bool = false
    @State var optionsOverride: String = ""
    
    enum DropState {
        case uninitiated
        case possible
        case forbidden
    }
    
    var body : some View {
        fileView
            .frame(minWidth: 320, idealWidth: 640, maxWidth: .infinity, minHeight: 200, alignment: .center)
            .onDrop(of: [(kUTTypeFileURL as String)], delegate: self)
    }
    
    var fileView: some View {
        switch dropState {
        case .uninitiated:
            if let operation = operation {
                return AnyView(
                    Form {
                        Section() {
                            Button(action: openFile) {
                                HStack {
                                    FileView(model: FileViewModel(inputFile: operation.input))
                                    
                                    Spacer()
                                    
                                    Button(
                                        action: { self.showingProbeOutput = true },
                                        label: { Text("􀅴").font(.system(size: 18)) }
                                    )
                                        .buttonStyle(LinkButtonStyle())
                                        .popover(
                                            isPresented: $showingProbeOutput,
                                            content: { self.probeOutput }
                                    )
                                }
                            }
                        .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                        
                        Divider()
                        
                        Section {
                            Spacer()
                            
                            TextField(
                                operation.options,
                                text: $optionsOverride,
                                onEditingChanged: { _ in },
                                onCommit: { }
                            )
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Section {
                            Button(action: changeOutput) {
                                HStack {
                                    FileView(model: FileViewModel(outputFile: operation.output))
                                        .opacity(operation.output.fileExists() ? 1.0 : 0.5)
                                    
                                    Spacer()
                                    
                                    Button(
                                        action: showOutputInFinder,
                                        label: { Image(nsImage: NSImage(named: NSImage.revealFreestandingTemplateName)!) }
                                    )
                                        .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal)
                        
                        Section {
                            HStack {
                                Button(
                                    action: { },
                                    label: { Text("Options…") }
                                )
                                
                                Spacer()
                                
                                Button(
                                    action: run,
                                    label: { Text("Run") }
                                )
                            }
                            .padding(.top, 8)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                )
            } else {
                return AnyView(
                    VStack {
                        Button(
                            action: openFile,
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
        guard let file = operation?.input else { return nil }
        return ProbeOutputView(file: file, probeOutput: FFprobe(file: file).run())
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
                self.operation = FFmpegOperation(input: url)
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
            guard response == .OK, let url = panel.url else { return }
            self.operation = FFmpegOperation(input: url)
        }
    }
    
    func changeOutput() {
        let panel = NSSavePanel()
        panel.title = "Choose output file"
        panel.canCreateDirectories = true
        panel.nameFieldStringValue = operation?.output.lastPathComponent ?? ""
        panel.directoryURL = operation?.output.deletingLastPathComponent()
        
        panel.beginSheetModal(for: window) { response in
            guard response == .OK, let url = panel.url else { return }
            self.operation?.output = url
        }
    }
    
    func showOutputInFinder() {
        guard let operation = operation else { return }
        if operation.output.fileExists() {
            NSWorkspace.shared.selectFile(operation.output.path, inFileViewerRootedAtPath: "")
        } else {
            NSWorkspace.shared.selectFile(operation.output.deletingLastPathComponent().path, inFileViewerRootedAtPath: "")
        }
    }
    
    func run() {
        
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(window: .init())
            
            ContentView(window: .init(), operation: FFmpegOperation(input: PreviewData.input))
        }
    }
}
