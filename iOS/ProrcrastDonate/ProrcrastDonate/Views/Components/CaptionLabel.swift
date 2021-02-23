//
//  CaptionLabel.swift
//  RChat
//
//  Created by Andrew Morgan on 23/11/2020.
//

import SwiftUI

struct CaptionLabel: View {
    @State var title: String
    
    init(_ title: String) {
        _title = State(initialValue: title)
    }
    
    private let lineLimit = 5

    var body: some View {
        HStack {
            Text(LocalizedStringKey(title))
                .font(.caption)
                .lineLimit(lineLimit)
                .multilineTextAlignment(.leading)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct CaptionLabel_Previews: PreviewProvider {
    static var previews: some View {
        AppearancePreviews(
            CaptionLabel("Title")
                .previewLayout(.sizeThatFits)
                .padding()
        )
    }
}
