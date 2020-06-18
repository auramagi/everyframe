//
//  ContentView.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/18.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI

struct ContentView: View, DropDelegate {
    
    @State var openedFile: URL?
    
    var fileView: some View {
        if let openedFile = openedFile {
            return AnyView(
                HStack(spacing: 0) {
                    DetailView(file: openedFile)
                    
                    Divider()
                    
                    Spacer().frame(minWidth: 200)
                }
            )
        } else {
            return AnyView(Text("Drop here"))
        }
    }
    
    var body : some View {
        fileView
            .edgesIgnoringSafeArea(.top)
            .frame(minWidth: 320, idealWidth: 640, maxWidth: .infinity, minHeight: 240, idealHeight: 480, maxHeight: .infinity, alignment: .center)
            .onDrop(of: [(kUTTypeFileURL as String)], delegate: self)
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        let proposal = DropProposal.init(operation: .copy)
        return proposal
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
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
