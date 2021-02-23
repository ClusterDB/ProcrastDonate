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
}
