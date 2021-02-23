//
//  LabelledDate.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI

struct LabelledDate: View {
    let title: String
    let date: Date
    var showingSecureField = false

    private enum Dimensions {
        static let noSpacing: CGFloat = 0
        static let bottomPadding: CGFloat = 16
    }

    var body: some View {
        VStack(spacing: Dimensions.noSpacing) {
            CaptionLabel(title)
            HStack {
                Text(date.fullDateTime())
                    .padding(.bottom, Dimensions.bottomPadding)
                    .foregroundColor(.primary)
                    .font(.body)
                Spacer()
            }
        }
    }
}

struct LabelledDate_Previews: PreviewProvider {
    static var previews: some View {
        AppearancePreviews(
            Group {
                LabelledDate(title: "This is a date", date: Date())
            }
            .previewLayout(.sizeThatFits)
            .padding()
        )
    }
}
