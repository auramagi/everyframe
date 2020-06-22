//
//  ContentView.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI

class ContentViewModel: ObservableObject, DropDelegate {
    
    @Published var didSetInput: Bool = false
    @Published var error: IdentifiableAppError?
    
    
    private var dropState: DropState = .uninitiated
    
    enum DropState {
        case uninitiated
        case possible
        case forbidden
    }
    
    private var operationViewModel: OperationViewModel? {
        didSet {
            didSetInput = operationViewModel != nil
        }
    }
    
    var windowTitle: String {
        operationViewModel?.operation.input.lastPathComponent ?? "New operation"
    }
    
    var isPerformingDrop: Bool {
        dropState != .uninitiated
    }
    
    var hasInput: Bool {
        operationViewModel != nil
    }
    
    var dropPrompt: String {
        dropState == .forbidden
            ? "Drop here"
            : "Can not drop here"
    }
    
    var inputPickerPrompt: String {
        "Choose input"
    }
    
    var operationView: OperationView? {
        operationViewModel.map { OperationView(viewModel: $0) }
    }
    
    func openFile(window: NSWindow?) {
        FilePicker.chooseInput(window: window!) { url in
            self.setInput(url)
        }
    }
    
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
    
}

struct ContentView: View {
    
    @ObservedObject var model: ContentViewModel
    
    @Environment(\.window) var window: NSWindow?
        
    var body : some View {
        makeView(model: model, window: window)
            .frame(minWidth: 320, idealWidth: 640, maxWidth: .infinity, minHeight: 200, alignment: .center)
            .environment(\.windowTitle, model.windowTitle)
            .onDrop(of: [(kUTTypeFileURL as String)], delegate: model)
            .alert(item: $model.error) { $0.error.makeAlert() }
    }
    
    @ViewBuilder func makeView(model: ContentViewModel, window: NSWindow?) -> some View {
        if model.isPerformingDrop {
            Text(model.dropPrompt)
        } else if model.hasInput  {
            model.operationView
        } else {
            Button(
                action: { model.openFile(window: window) },
                label: { Text(self.model.inputPickerPrompt) }
            )
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
