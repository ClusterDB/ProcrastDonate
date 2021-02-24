//
//  Tag.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 24/02/2021.
//

import SwiftUI

struct Tag: View {
    let text: String
    var showingButton = false
    var delete: () -> Void = {}
    
    private enum Dimensions {
        static let noPadding: CGFloat = 4.0
        static let smallPadding: CGFloat = 4.0
        static let mediumPadding: CGFloat = 8.0
    }
    
    init(_ text: String, hasAction: Bool = true, _ delete: @escaping () -> Void = {}) {
        self.text = text
        showingButton = hasAction
        self.delete = delete
    }
    
    var body: some View {
        HStack {
            Text(text)
            if showingButton {
                Button(action: delete) {
                    Image(systemName: "xmark.circle")
                        .padding(Dimensions.smallPadding)
                }
            }
        }
        .font(.caption)
        .padding(.leading, Dimensions.mediumPadding)
        .padding(.trailing, showingButton ? Dimensions.noPadding : Dimensions.mediumPadding)
        .padding(.vertical, showingButton ? Dimensions.noPadding : Dimensions.smallPadding)
        .foregroundColor(.primary)
        .background(Color.secondary)
        .clipShape(Capsule())
    }
}

struct Tag_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            Tag("test text") {}
            Tag("no action", hasAction: false) {}
        }
    }
}
