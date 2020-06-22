//
//  OperationView.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/20.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI
import Combine

class OperationViewModel: ObservableObject {
    
    @Published var operation: FFmpegOperation
    @Published var optionsOverride: String = ""
    @Published var executionState: ExecutionState = .uninitiated
    
    var onError: ((AppError) -> Void)?
    
    private var subscriptions: Set<AnyCancellable> = []
    
    enum ExecutionState {
        case uninitiated
        case started
        case running(progress: [String: String])
        
        var isRunning: Bool {
            if case .uninitiated = self {
                return false
            } else {
                return true
            }
        }
        
        var progress: [String: String] {
            if case let .running(progress) = self {
                return progress
            } else {
                return [:]
            }
        }
    }
    
    init(operation: FFmpegOperation) {
        self._operation = .init(initialValue: operation)
    }
    
    func setInput(_ input: URL) {
        FFmpegOperation.make(input: input).unwrap(
            onFailure: onError,
            onSuccess: { self.operation = $0 }
        )
    }
    
    func setOutput(_ output: URL) {
        operation.output = output
    }
    
    var outputFileExists: Bool {
        executionState.isRunning
            ? false
            : operation.output.fileExists()
    }
    
    func showOutputInFinder() {
        if operation.output.fileExists() {
            NSWorkspace.shared.selectFile(operation.output.path, inFileViewerRootedAtPath: "")
        } else {
            NSWorkspace.shared.selectFile(operation.output.deletingLastPathComponent().path, inFileViewerRootedAtPath: "")
        }
    }
    
    func run() {
        executionState = .started
        FFmpeg(operation: operation)
            .run()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { _ in self.executionState = .uninitiated },
                receiveValue: { self.executionState = .running(progress: $0) }
            ).store(in: &subscriptions)
    }
    
    func processOptionsOverride(_ editing: Bool) {
        operation.optionsOverride = optionsOverride.isEmpty
            ? nil
            : optionsOverride
    }
    
}

struct OperationView: View {
    
    @ObservedObject var viewModel: OperationViewModel
    @State var showingProbeOutput: Bool = false
    @State var showingProgress: Bool = true
    
    @Environment(\.window) var window: NSWindow?
    
    var body: some View {
        Form {
            Section() {
                Button(action: openFile) {
                    HStack {
                        FileView(model: FileViewModel(inputFile: viewModel.operation.input))
                        
                        Spacer()
                        
                        PopoverToggleButton(
                            condition: $showingProbeOutput,
                            label: { Text("􀅴").font(.system(size: 18)) },
                            content: makeProbeOutputPopover
                        ).buttonStyle(LinkButtonStyle())
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            
            Divider()
            
            Section {
                Spacer()
                
                TextField(
                    viewModel.operation.options,
                    text: $viewModel.optionsOverride,
                    onEditingChanged: viewModel.processOptionsOverride,
                    onCommit: { }
                )
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Spacer()
            }
            .padding(.horizontal)
            
            Section {
                Button(action: changeOutput) {
                    HStack {
                        FileView(model: FileViewModel(outputFile: viewModel.operation.output))
                            .opacity(viewModel.outputFileExists ? 1.0 : 0.5)
                        
                        Spacer()
                        
                        Button(
                            action: viewModel.showOutputInFinder,
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
                        label: { Text("Preferences…") }
                    )
                    
                    Spacer()
                    
                    makeRunButton()
                }
                .padding(.top, 8)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
        
    @ViewBuilder func makeRunButton() -> some View {
        if viewModel.executionState.isRunning {
            PopoverToggleButton(
                condition: $showingProgress,
                label: { ActivityIndicatorView().environment(\.controlSize, .small) },
                content: makeProgressPopover
            )
        } else {
            Button(
                action: run,
                label: { Text("Run") }
            )
        }
    }
    
    func makeProbeOutputPopover() -> some View {
        ProbeOutputView(file: viewModel.operation.input, output: viewModel.operation.inputProbe)
    }
    
    func makeProgressPopover() -> some View {
        ProgressView(progress: self.viewModel.executionState.progress)
            .frame(minWidth: 180)
    }
    
    func run() {
        viewModel.run()
        showingProgress = true
    }
    
    func openFile() {
        FilePicker.chooseInput(window: window!) { url in
            self.viewModel.setInput(url)
        }
    }
    
    func changeOutput() {
        FilePicker.chooseOutput(window: window!, prompt: viewModel.operation.output) { url in
            self.viewModel.setOutput(url)
        }
    }
    
}

struct PopoverToggleButton<Label: View, Content: View>: View {
    
    @Binding var condition: Bool
    private var labelBuilder: () -> Label
    private var contentBuilder: () -> Content
    
    init(condition: Binding<Bool>, @ViewBuilder label: @escaping () -> Label, @ViewBuilder content: @escaping () -> Content) {
        self._condition = condition
        self.labelBuilder = label
        self.contentBuilder = content
    }
    
    var body: some View {
        Button(action: { self.condition.toggle() }, label: labelBuilder)
            .popover(isPresented: $condition, content: contentBuilder)
    }
    
}

struct OperationView_Previews: PreviewProvider {
    static var previews: some View {
        OperationView(viewModel: OperationViewModel(operation: PreviewData.operation))
    }
}
