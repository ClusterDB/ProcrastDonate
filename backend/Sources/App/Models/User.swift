import MongoDBVapor
import Foundation

struct User: Codable {
    let _id: BSONObjectID
    let username: String
    let displayName: String
    let email: String
    let password: String
    let bio: String
    let friends: [BSONObjectID]
}
