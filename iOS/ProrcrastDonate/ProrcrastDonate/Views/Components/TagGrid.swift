//
//  TagGrid.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 24/02/2021.
//

import SwiftUI

struct TagGrid: View {
    let tags: [String]

    private let rows = [
        GridItem(.flexible())
    ]
    
    private enum Dimensions {
        static let spacing: CGFloat = 4
        static let height: CGFloat = 50.0
        static let width: CGFloat = 80.0
    }
    
    init(_ tags: [String]) {
        self.tags = tags
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            LazyHGrid(rows: rows, alignment: .center, spacing: Dimensions.spacing) {
                ForEach(tags, id: \.self) { tag in
                    Tag(tag, hasAction: false)
                }
            }
        }
        .frame(maxWidth: Dimensions.width)
    }
}

struct TagGrid_Previews: PreviewProvider {
    static var previews: some View {
        TagGrid(["tag 1", "tag2", "tag3", "tag4", "tag5"])
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
