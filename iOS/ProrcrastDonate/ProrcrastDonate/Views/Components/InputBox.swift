//
//  InputBox.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 24/02/2021.
//

import SwiftUI

struct InputBox: View {
    var placeholder: String = "New value"
    @Binding var newText: String
    var action: () -> Void = {}

    private enum Dimensions {
        static let inset: CGFloat = 7.0
        static let bottomInset: CGFloat = 4.0
        static let heightTextField: CGFloat = 36.0
        static let cornerRadius: CGFloat = 10.0
        static let padding: CGFloat = 16.0
        static let topPadding: CGFloat = 15.0
        static let glassSize: CGFloat = 24.0
        static let dividerHeight: CGFloat = 1.0
    }

    var body: some View {
        VStack {
            HStack {
                Button(action: action) {
                    Image(systemName: "plus.app.fill")
                        .frame(width: Dimensions.glassSize, height: Dimensions.glassSize)
                }
                .disabled(newText == "")
                TextField(placeholder,
                          text: $newText
                )
                .disableAutocorrection(true)
                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                .font(.body)
            }
            .padding(EdgeInsets(top: Dimensions.inset, leading: Dimensions.bottomInset, bottom: Dimensions.inset, trailing: Dimensions.inset))
            .frame(height: Dimensions.heightTextField)
//            .foregroundColor(.secondary)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(Dimensions.cornerRadius)
            .padding([.horizontal, .top], Dimensions.padding)
            Divider()
                .padding(.top, Dimensions.topPadding)
                .frame(height: Dimensions.dividerHeight)
        }
    }
}

struct InputBox_Previews: PreviewProvider {
    static var previews: some View {
        InputBox(newText: .constant(""))
    }
}
