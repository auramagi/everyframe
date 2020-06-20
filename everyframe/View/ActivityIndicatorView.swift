//
//  ActivityIndicatorView.swift
//  everyframe
//
//  Created by Mikhail Apurin on 2020/06/20.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI

struct ActivityIndicatorView: NSViewRepresentable {
    
    let controlSize: NSControl.ControlSize
    
    func makeNSView(context: Context) -> NSProgressIndicator {
        let nsView = NSProgressIndicator()
        nsView.style = .spinning
        nsView.controlSize = controlSize
        nsView.startAnimation(nil)
        return nsView
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
        
    }
    
}


struct ActivityIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityIndicatorView(controlSize: .mini)
    }
}
