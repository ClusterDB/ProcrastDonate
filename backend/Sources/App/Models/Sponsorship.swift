import Foundation
import MongoDBVapor
import Vapor

struct Sponsorship: Codable {
    let _id: BSONObjectID
    let task: BSONObjectID
    let sponsor: BSONObjectID
    let comment: String
    let donationAmount: MonetaryValue
    let startDate: Date
    let cancelDate: Date?
    let settled: Bool
}

struct SponsorshipContent: Content {
    let _id: BSONObjectID
    let task: Task
    let comment: String
    let donationAmount: MonetaryValue
    let startDate: Date
    let cancelDate: Date?
    let settled: Bool
}
