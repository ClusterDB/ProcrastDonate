import Foundation
import MongoDBVapor
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
    let donationAmount: MonetaryValue
    let donateOnFailure: Bool
    let charity: BSONObjectID
    let tags: [String]

    init(
        title: String,
        user: BSONObjectID,
        descriptionText: String,
        deadlineDate: Date,
        donationAmount: MonetaryValue,
        donateOnFailure: Bool,
        charity: BSONObjectID,
        tags: [String]
    ) {
        self._id = BSONObjectID()
        self.title = title
        self.user = user
        self.descriptionText = descriptionText
        self.startDate = Date()
        self.completedDate = nil
        self.cancelDate = nil
        self.deadlineDate = deadlineDate
        self.donationAmount = donationAmount
        self.donateOnFailure = donateOnFailure
        self.charity = charity
        self.tags = tags
    }

    var isActive: Bool {
        self.deadlineDate > Date() && self.cancelDate == nil && self.completedDate == nil
    }
}
