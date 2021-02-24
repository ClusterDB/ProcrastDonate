import MongoDBVapor
import Foundation
import Vapor

struct User: Codable {
    let _id: BSONObjectID
    let username: String
    let displayName: String
    let email: String
    let password: String
    let bio: String
    let friends: [BSONObjectID]

    func toContent() -> UserContent {
        UserContent(_id: self._id, username: self.username, displayName: self.displayName, email: self.email, bio: self.bio, friends: self.friends)
    }
}

struct UserContent: Content {
    let _id: BSONObjectID
    let username: String
    let displayName: String
    let email: String
    let bio: String
    let friends: [BSONObjectID]
}
