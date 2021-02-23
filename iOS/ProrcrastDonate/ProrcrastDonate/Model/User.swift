//
//  User.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import SwiftUI
import RealmSwift

class User: ObservableObject, Identifiable {
    @Published var _id = ObjectId()
    @Published var userName = ""
    @Published var displayName = ""
    @Published var email = ""
    @Published var password = "" // Should be hashed
    @Published var bio = ""
    @Published var friends = [ObjectId]()
    
    var id: String { _id.stringValue }
    
    convenience init(
        _id: ObjectId = ObjectId(),
        userName: String,
        displayName: String,
        email: String,
        password: String,
        bio: String,
        friends: [ObjectId] = []
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
