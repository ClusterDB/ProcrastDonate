//
//  NumberInputField.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI

struct NumberInputField: View {

    let title: String
    @Binding var value: Int
    
    private var valueBinding: Binding<String> {
        Binding<String>(
            get: { "\(value)" },
            set: {
                let numberFormatter = NumberFormatter()
                value = numberFormatter.number(from: $0)?.intValue ?? 0
            })
    }
    
    private enum Dimensions {
        static let noSpacing: CGFloat = 0
        static let bottomPadding: CGFloat = 16
    }

    var body: some View {
        VStack(spacing: Dimensions.noSpacing) {
            CaptionLabel(title)
            TextField("", text: valueBinding)
                .keyboardType(.decimalPad)
                .padding(.bottom, Dimensions.bottomPadding)
                .foregroundColor(.primary)
                .font(.body)
        }
    }
}

struct NumberInputField_Previews: PreviewProvider {
    static var previews: some View {
        AppearancePreviews(
            NumberInputField(title: "Input", value: .constant(42))
            .previewLayout(.sizeThatFits)
            .padding()
        )
    }
}
