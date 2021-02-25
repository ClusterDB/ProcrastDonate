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

    static func queryFilter(forID id: BSONObjectID, isActive: Bool) -> BSONDocument {
        var filter: BSONDocument = ["_id": .objectID(id)]
        if isActive {
            filter["completedDate"] = ["$exists": false]
            filter["cancelledDate"] = ["$exists": false]
        }
        return filter
    }
}

enum TaskUpdateRequest: Content {
    case markAsCompleted

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            guard string == "mark-as-completed" else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unexpected action string")
            }
            self = .markAsCompleted
            return
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "invalid update request")
    }

    func encode(to encoder: Encoder) throws {
        switch self {
        case .markAsCompleted:
            var container = encoder.singleValueContainer()
            try container.encode("mark-as-completed")
        }
    }
}
