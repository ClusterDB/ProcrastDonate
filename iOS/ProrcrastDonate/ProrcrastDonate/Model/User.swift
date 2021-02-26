//
//  User.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI
import SwiftBSON

class User: ObservableObject, Identifiable {
    @Published var _id = BSONObjectID()
    @Published var userName = ""
    @Published var displayName = ""
    @Published var email = ""
    @Published var password = "" // Should be hashed
    @Published var bio = ""
    @Published var friends = [BSONObjectID]()
    
    var id: String { _id.description }
    
    init() {}
    
    convenience init(
        _id: BSONObjectID = BSONObjectID(),
        userName: String,
        displayName: String,
        email: String,
        password: String,
        bio: String,
        friends: [BSONObjectID] = []
    ) {
        self.init()
        self._id = _id
        self.userName = userName
        self.displayName = displayName
        self.email = email
        self.password = password
        self.bio = bio
        self.friends.append(contentsOf: friends)
    }
    
    enum CodingKeys: CodingKey {
        case _id
        case userName
        case displayName
        case email
        case bio
        case password
        case friends
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        _id = try container.decode(BSONObjectID.self, forKey: ._id)
        userName = try container.decode(String.self, forKey: .userName)
        displayName = try container.decode(String.self, forKey: .displayName)
        email = try container.decode(String.self, forKey: .email)
        password = try container.decode(String.self, forKey: .password)
        bio = try container.decode(String.self, forKey: .bio)
        friends = try container.decode([BSONObjectID].self, forKey: .friends)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(_id, forKey: ._id)
        try container.encode(userName, forKey: .userName)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(email, forKey: .email)
        try container.encode(password, forKey: .password)
        try container.encode(bio, forKey: .bio)
        try container.encode(friends, forKey: .friends)
    }
}
