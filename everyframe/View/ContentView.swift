//
//  ContentView.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI

struct ContentView: View, DropDelegate {
    
    @State var operationViewModel: OperationViewModel?
    @State var dropState: DropState = .uninitiated
    
    @Environment(\.window) var window: NSWindow?
    
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
            if let operationViewModel = operationViewModel {
                return AnyView(
                    OperationView(viewModel: operationViewModel)
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
            return AnyView(Text("Can not drop here"))
        }
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
                self.setInput(url)
            }
        }
        
        return true
    }
    
    func openFile() {
        FilePicker.chooseInput(window: window!) { url in
            self.setInput(url)
        }
    }
    
    func setInput(_ url: URL) {
        operationViewModel = .init(operation: .init(input: url))
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
