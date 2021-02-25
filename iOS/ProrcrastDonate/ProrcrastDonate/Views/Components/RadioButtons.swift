//
//  RadioButtons.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 25/02/2021.
//

import SwiftUI

struct RadioButtons: View {
    @State private var favoriteColor = false

    var body: some View {
        VStack {
            Picker(selection: $favoriteColor, label: Text("When should the donation be made?")) {
                Text("Completion").tag(false)
                Text("Expiration").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())

            Text("Value: \(favoriteColor ? "true" : "false")")
        }
    }
}

struct RadioButtons_Previews: PreviewProvider {
    static var previews: some View {
        RadioButtons()
    }
}
