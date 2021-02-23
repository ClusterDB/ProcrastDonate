//
//  TextEditorField.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI

struct TextEditorField: View {
    let title: String
    @Binding private(set) var text: String

    private enum Dimensions {
        static let maxHeight: CGFloat = 100
        static let minHeight: CGFloat = 100
        static let noSpacing: CGFloat = 0
        static let bottomPadding: CGFloat = 16
    }

    var body: some View {
        VStack(spacing: Dimensions.noSpacing) {
            CaptionLabel(title)
            TextEditor(text: $text)
                .padding(.bottom, Dimensions.bottomPadding)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: Dimensions.minHeight, maxHeight: Dimensions.maxHeight)
                .foregroundColor(.primary)
                .font(.body)
        }
    }
}

struct TextEditorField_Previews: PreviewProvider {
    static var previews: some View {
        let inputText = """
        This is where you can edit multi-line text.
        This is the second line.
        This is the third.
        """
        
        return AppearancePreviews(
            Group {
                TextEditorField(title: "Input", text: .constant(inputText))
            }
            .previewLayout(.sizeThatFits)
            .padding()
        )
    }
}
