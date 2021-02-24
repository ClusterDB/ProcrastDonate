import Foundation
import MongoDBVapor

struct Charity: Codable {
    let _id: BSONObjectID
    let name: String
    let descriptionText: String
    let website: String
}
