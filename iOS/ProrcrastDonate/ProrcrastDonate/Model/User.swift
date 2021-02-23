//
//  User.swift
//  ProrcrastDonate
//
//  Created by Andrew Morgan on 23/02/2021.
//

import RealmSwift

@objcMembers class User: Object, ObjectKeyIdentifiable {
    dynamic var _id = ObjectId()
    dynamic var userName = ""
    dynamic var displayName = ""
    dynamic var email = ""
    dynamic var password = "" // Should be hashed
    dynamic var bio = ""
    var friends = List<ObjectId>()
    
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
        for friend in friends {
            self.friends.append(friend)
        }
    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
}
