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
    var showingSecureField = false

    private enum Dimensions {
        static let noSpacing: CGFloat = 0
        static let bottomPadding: CGFloat = 16
        static let iconSize: CGFloat = 20
    }

    var body: some View {
        VStack(spacing: Dimensions.noSpacing) {
            CaptionLabel(title: title)
            HStack(spacing: Dimensions.noSpacing) {
                if showingSecureField {
                    SecureField("", text: $text)
                        .padding(.bottom, Dimensions.bottomPadding)
                        .foregroundColor(.primary)
                        .font(.body)
                } else {
                    TextField("", text: $text)
                        .padding(.bottom, Dimensions.bottomPadding)
                        .foregroundColor(.primary)
                        .font(.body)
                }
            }
        }
    }
}

struct TextEditorField_Previews: PreviewProvider {
    static var previews: some View {
        AppearancePreviews(
            Group {
                TextEditorField(title: "Input", text: .constant("Data"))
                TextEditorField(title: "Input secure", text: .constant("Data"), showingSecureField: true)
            }
            .previewLayout(.sizeThatFits)
            .padding()
        )
    }
}
