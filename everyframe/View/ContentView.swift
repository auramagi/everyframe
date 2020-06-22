//
//  ContentView.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI

class ContentViewModel: ObservableObject {
    
    @Published var operationViewModel: OperationViewModel?
    @Published var error: IdentifiableAppError?
    
    
    func setInput(_ url: URL?) {
        if let url = url {
            FFmpegOperation.make(input: url).unwrap(
                onFailure: handleError,
                onSuccess: { self.operationViewModel = OperationViewModel(operation: $0) }
            )
        } else {
            operationViewModel = nil
        }
    }
    
    func handleError(_ error: AppError) {
        self.error = IdentifiableAppError(error: error)
    }
    
}

struct ContentView: View, DropDelegate {
    
    @ObservedObject var model: ContentViewModel
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
            .environment(\.windowTitle, model.operationViewModel?.operation.input.lastPathComponent ?? "New operation")
            .onDrop(of: [(kUTTypeFileURL as String)], delegate: self)
            .alert(item: $model.error) { $0.error.makeAlert() }
    }
    
    var fileView: some View {
        switch dropState {
        case .uninitiated:
            if let operationViewModel = model.operationViewModel {
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
                self.model.setInput(url)
            }
        }
        
        return true
    }
    
    func openFile() {
        FilePicker.chooseInput(window: window!) { url in
            self.model.setInput(url)
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView(model: .init())
        }
    }
}
