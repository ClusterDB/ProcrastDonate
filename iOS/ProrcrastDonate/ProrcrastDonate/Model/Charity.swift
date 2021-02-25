//
//  Charity.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI
import SwiftBSON

class Charity: ObservableObject, Identifiable, Codable {
    @Published var _id: BSONObjectID
    @Published var name: String
    @Published var descriptionText: String
    @Published var website: String
    
    init() {
        _id = BSONObjectID()
        name = ""
        descriptionText = ""
        website = ""
    }
    
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
    
    enum CodingKeys: CodingKey {
        case _id
        case name
        case descriptionText
        case website
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(BSONObjectID.self, forKey: ._id)
        name = try container.decode(String.self, forKey: .name)
        descriptionText = try container.decode(String.self, forKey: .descriptionText)
        website = try container.decode(String.self, forKey: .website)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(name, forKey: .name)
        try container.encode(descriptionText, forKey: .descriptionText)
        try container.encode(website, forKey: .website)
    }
}
