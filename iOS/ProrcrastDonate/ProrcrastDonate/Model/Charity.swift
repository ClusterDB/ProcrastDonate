//
//  Charity.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI
import RealmSwift

class Charity: ObservableObject, Identifiable {
    @Published var _id = ObjectId()
    @Published var name = ""
    @Published var description = ""
    @Published var website = ""

    convenience init(
        _id: ObjectId = ObjectId(),
        name: String,
        description: String,
        website: String
    ) {
        self.init()
        self._id = _id
        self.name = name
        self.description = description
    }
}
