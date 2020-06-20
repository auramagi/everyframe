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
        operation = FFmpegOperation(input: input)
    }
    
    func setOutput(_ output: URL) {
        operation.output = output
    }
    
    var outputFileExists: Bool {
        executionState.isRunning
            ? false
            : operation.output.fileExists()
    }
    
    var probeOutput: Any? {
        FFprobe(file: operation.input).run()
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
                        
                        Button(
                            action: { self.showingProbeOutput = true },
                            label: { Text("􀅴").font(.system(size: 18)) }
                        )
                            .buttonStyle(LinkButtonStyle())
                            .popover(isPresented: $showingProbeOutput, content: makeProbeOutputPopover)
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
                    
                    runButton
                }
                .padding(.top, 8)
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
    
    var runButton: some View {
        if viewModel.executionState.isRunning {
            return AnyView(
                Button(
                    action: { self.showingProgress = true },
                    label: { ActivityIndicatorView(controlSize: .small) }
                )
                    .buttonStyle(BorderlessButtonStyle())
                    .popover(isPresented: $showingProgress, content: makeProgressPopover)
            )
        } else {
            return AnyView(
                Button(
                    action: run,
                    label: { Text("Run") }
                )
            )
        }
    }
    
    func makeProbeOutputPopover() -> some View {
        ProbeOutputView(file: viewModel.operation.input, probeOutput: viewModel.probeOutput)
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

struct OperationView_Previews: PreviewProvider {
    static var previews: some View {
        OperationView(viewModel: OperationViewModel(operation: FFmpegOperation(input: PreviewData.input)))
    }
}
