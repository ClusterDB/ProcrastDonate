//
//  CharityView.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 24/02/2021.
//

import SwiftUI
import SwiftBSON

struct CharityView: View {
    @EnvironmentObject var state: AppState
    
    @Binding var charityID: BSONObjectID?
    
    @State var charities = [Charity]()
    @State var charityNames = [String]()
    @State var selectedCharity: Charity?
    @State var showingPicker = false
    
    var body: some View {
        VStack {
            Button(action: {
                    showingPicker .toggle()
            }) {
                if let selectedCharity = selectedCharity {
                    LabeledText(label: "Charity", text: "\(selectedCharity.name) (\(selectedCharity.website)): \(selectedCharity.descriptionText)")
                } else {
                    LabeledText(label: "Charity", text: "Select Charity")
                }
            }
            if showingPicker {
                CharityPickerView(charityID: $charityID)
            }
        }
        .onAppear(perform: loadCharities)
        .onChange(of: charityID, perform: { value in
            selectedCharity = charities.first(where: { $0._id == value })
        })
    }
    
    func loadCharities() {
        if state.localMode {
            charities = Charity.samples
        } else {
            // TODO: Fetch from backend
            charities = Charity.samples
        }
        selectedCharity = charities.first(where: { $0._id == charityID })
    }
}

struct CharityView_Previews: PreviewProvider {
    static var previews: some View {
        CharityView(charityID: .constant(Charity.sample3._id))
            .environmentObject(AppState())
    }
}
