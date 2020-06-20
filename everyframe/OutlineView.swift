
//
//  OutlineView.swift
//  NSTreeController
//
//  Created by Mikhail Apurin on 2020/06/20.
//  Copyright © 2020 Mikhail Apurin. All rights reserved.
//

import SwiftUI

@objcMembers class JSONObjectTreeNode: NSObject {
    let object: Any
    let key: String?
    let value: String?
    let isLeaf: Bool
    let childObjects: [(key: String, value: Any)]
    
    init(object: Any, key: String? = nil) {
        self.object = object
        self.key = key
        if let text = object as? String {
            self.value = text
            self.isLeaf = true
            self.childObjects = []
        } else if let number = object as? NSNumber {
            self.value = number.stringValue
            self.isLeaf = true
            self.childObjects = []
        } else if let array = object as? [Any] {
            self.value = nil
            self.isLeaf = false
            self.childObjects = array
                .enumerated()
                .map { (key: String($0.offset), value: $0.element) }
        } else if let dictionary = object as? [String: Any] {
            self.value = nil
            self.isLeaf = false
            self.childObjects = dictionary
                .sorted(by: { $0.key < $1.key })
        } else {
            self.value = "nil" // show values that we couldn't recognize
            self.isLeaf = true
            self.childObjects = []
        }
    }
    
    var children: [JSONObjectTreeNode] {
        childObjects.map { JSONObjectTreeNode(object: $0.value, key: $0.key) }
    }
    
    var childCount: Int { childObjects.count }
    
}

struct OutlineView: NSViewRepresentable {
    let contents: [JSONObjectTreeNode]
    
    init(object: Any, flattenTopLevelContainer: Bool = false) {
        let object = JSONObjectTreeNode(object: object)
        if flattenTopLevelContainer, !object.isLeaf {
            self.contents = object.children
        } else {
            self.contents = [object]
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(contents: contents)
    }
    
    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        let outline = context.coordinator.outline
        scrollView.documentView = outline
        return scrollView
    }
    
    func updateNSView(_ nsView: NSScrollView, context: Context) {
        
    }
    
    @objcMembers class Coordinator: NSObject, NSOutlineViewDataSource {
        let contents: [JSONObjectTreeNode]
        let tree = NSTreeController()
        lazy var outline: NSOutlineView = makeOutlineView()
        
        init(contents: [JSONObjectTreeNode]) {
            self.contents = contents
        }

        private static let firstColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "0")
        private static let secondColumnIdentifier = NSUserInterfaceItemIdentifier(rawValue: "1")
        
        private func makeOutlineView() -> NSOutlineView {
            tree.leafKeyPath = #keyPath(JSONObjectTreeNode.isLeaf)
            tree.countKeyPath = #keyPath(JSONObjectTreeNode.childCount)
            tree.childrenKeyPath = #keyPath(JSONObjectTreeNode.children)
            
            tree.bind(.contentArray, to: self, withKeyPath: #keyPath(contents), options: nil)
            
            let outline = NSOutlineView()
            
            let column1 = NSTableColumn(identifier: Coordinator.firstColumnIdentifier)
            let column2 = NSTableColumn(identifier: Coordinator.secondColumnIdentifier)
            outline.addTableColumn(column1)
            outline.addTableColumn(column2)
            outline.dataSource = self
            
            outline.headerView = nil
            
            outline.bind(.content, to: tree, withKeyPath: #keyPath(NSTreeController.arrangedObjects), options: nil)
            outline.expandItem(nil, expandChildren: true)
            
            return outline
        }
        
        func outlineView(_ outlineView: NSOutlineView, objectValueFor tableColumn: NSTableColumn?, byItem item: Any?) -> Any? {
            guard let node = (item as? NSTreeNode)?.representedObject as? JSONObjectTreeNode else { return nil }
            switch tableColumn?.identifier {
            case Coordinator.firstColumnIdentifier:
                return (node.key ?? node.value)?.transformingSnakeCaseToHumanReadable()
                
            case Coordinator.secondColumnIdentifier:
                return node.key == nil ? nil : node.value
                
            default:
                return nil
            }
        }
        
        // Required NSOutlineViewDataSource methods, but not actually used when using Cocoa bindings with NSTreeController
        func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int { 0 }
        func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool { false }
        func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any { 0 }
    }
}

struct OutlineView_Previews: PreviewProvider {
    static var previews: some View {
        OutlineView(object: [["Test1": "Test2"], ["Test3": "Test4"], ["Test5": "Test6"], ["Test": "Test"]])
    }
}
