//
//  Charity.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI
import SwiftBSON

class Charity: ObservableObject, Identifiable {
    @Published var _id = BSONObjectID()
    @Published var name = ""
    @Published var descriptionText = ""
    @Published var website = ""

    convenience init(
        _id: BSONObjectID = BSONObjectID(),
        name: String,
        descriptionText: String,
        website: String
    ) {
        self.init()
        self._id = _id
        self.name = name
        self.descriptionText = descriptionText
        self.website = website
    }
}
