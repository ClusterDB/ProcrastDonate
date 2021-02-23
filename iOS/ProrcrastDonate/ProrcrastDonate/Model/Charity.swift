//
//  Charity.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import RealmSwift

@objcMembers class Charity: Object, ObjectKeyIdentifiable {
    dynamic var _id = ObjectId()
    dynamic var name = ""
    dynamic var charityDescription = "" // Can't use "description" as it's used by the base protocol
    dynamic var website = ""

    convenience init(
        _id: ObjectId = ObjectId(),
        name: String,
        charityDescription: String,
        website: String
    ) {
        self.init()
        self._id = _id
        self.name = name
        self.charityDescription = charityDescription
    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
}
