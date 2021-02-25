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

    init(from newSponsorship: NewSponsorship, sponsor: BSONObjectID) {
        self._id = BSONObjectID()
        self.task = newSponsorship.task
        self.sponsor = sponsor
        self.comment = newSponsorship.comment
        self.donationAmount = newSponsorship.donationAmount
        self.startDate = Date()
        self.cancelDate = nil
        self.settled = false
    }

    static func queryFilter(forTask id: BSONObjectID, isActive: Bool) -> BSONDocument {
        var filter: BSONDocument = ["task": .objectID(id)]
        if isActive {
            filter["cancelledDate"] = ["$exists": false]
        }
        return filter
    }
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

struct NewSponsorship: Content {
    let task: BSONObjectID
    let comment: String
    let donationAmount: MonetaryValue
}
