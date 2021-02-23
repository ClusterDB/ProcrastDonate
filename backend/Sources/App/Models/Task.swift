import MongoDBVapor
import Foundation
import Vapor

struct Task: Content {
    let _id: BSONObjectID
    let title: String
    let user: BSONObjectID
    let descriptionText: String
    let startDate: Date
    let completedDate: Date?
    let cancelDate: Date?
    // let renewals: [BSONDocument]
    let deadlineDate: Date
    let donationAmount: BSONDocument
    let donateOnFailure: Bool
    let charity: BSONObjectID
    let tags: [String]
}
