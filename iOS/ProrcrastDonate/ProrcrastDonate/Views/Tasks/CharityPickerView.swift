//
//  CharityPickerView.swift
//  ProcrastDonate
//
//  Created by Andrew Morgan on 24/02/2021.
//

import SwiftUI
import SwiftBSON

struct CharityPickerView: View {
    @EnvironmentObject var state: AppState
    
    @Binding var charityID: BSONObjectID?
    
    @State var charities = [Charity]()
    @State var charityNames = [String]()
    @State var selectedCharityName = ""
    
    var body: some View {
        Picker("Select charity", selection: $selectedCharityName) {
            ForEach(charityNames, id: \.self) {
                Text($0)
            }
        }
        .onChange(of: selectedCharityName, perform: { value in
            charityID = charities.first(where: { $0.name == value })?._id
        })
        .onAppear(perform: loadCharities)
    }
    
    func loadCharities() {
        if state.localMode {
            charities = Charity.samples
        } else {
            // TODO: Fetch from backend
            charities = Charity.samples
        }
        if let charity = charities.first(where: { $0._id == charityID }) {
            selectedCharityName = charity.name
        }
        charityNames = charities.map({ $0.name })
    }
}

struct CharityPickerView_Previews: PreviewProvider {
    static var previews: some View {
        CharityPickerView(charityID: .constant(Charity.sample._id))
            .environmentObject(AppState())
    }
}
