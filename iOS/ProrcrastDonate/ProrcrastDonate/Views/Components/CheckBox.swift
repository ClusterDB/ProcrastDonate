//
//  CheckBox.swift
//  RChat
//
//  Created by Andrew Morgan on 18/12/2020.
//

import SwiftUI

struct CheckBox: View {
    @Binding var isChecked: Bool
    var action: () -> Void = {}

    var body: some View {
        Button(action: { self.isChecked.toggle() }) {
            Image(systemName: isChecked ? "checkmark.square": "square")
                .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .foregroundColor(.primary)
    }
}

struct CheckBox_Previews: PreviewProvider {
    static var previews: some View {
        AppearancePreviews(
            VStack {
                CheckBox(isChecked: .constant(true))
                CheckBox(isChecked: .constant(false))
            }
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
