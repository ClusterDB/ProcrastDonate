import Foundation
import MongoDBVapor
import Vapor

struct MonetaryValue: Codable, Equatable {
    enum Currency: String, Codable, Equatable {
        case USD
    }

    /// 1/100th units of the given currency. e.g. 1 cent in USD
    let amount: UInt

    /// The type of currency
    let currency: Currency

    init(dollars: UInt, cents: UInt) {
        self.amount = dollars * 100 + cents
        self.currency = .USD
    }
}

/// Options determining the sort / limit / delimiters of a task or sponsorship based query.
struct QueryOptions: Content {
    enum SortBy: String, Codable {
        /// Items will be returned in order from earliest deadline to latest, with the date delimiter determining
        /// the earliest possible deadline.
        case earliestDeadline = "earliest-deadline"

        /// Items will be returned in order from latest start to earliest (newest to oldest), with the date delimiter
        /// determining the newest possible task.
        case latestStart = "latest-start"
    }

    /// Whether to only return tasks that have not been completed, passed their deadline, or been cancelled.
    let activeOnly: Bool?

    /// The maximum number of tasks to return.
    let limit: Int?

    /// Which criteria will be used to determine the order in which records are returned.
    let sortBy: SortBy

    /// Either the latest possible start date or the earliest possible deadline, depending on sortBy.
    /// Must be a valid ISO-8601 formatted string.
    let dateDelimiter: Date?

    enum CodingKeys: String, CodingKey {
        case activeOnly = "active-only"
        case limit
        case sortBy = "sort-by"
        case dateDelimiter = "date-delimiter"
    }

    func updateFilter(_ filter: inout BSONDocument, deadlinePrefix: String = "", startPrefix: String = "") throws {
        let startDate = Date()
        // this value will be used as either the latest start date or the earliest deadline, depending on sortBy
        let dateDelimiter = self.dateDelimiter ?? startDate

        switch self.sortBy {
        case .latestStart:
            filter["\(startPrefix)startDate"] = ["$lt": .datetime(dateDelimiter)]
        case .earliestDeadline:
            filter["\(deadlinePrefix)deadlineDate"] = ["$gt": .datetime(dateDelimiter)]
        }

        if self.activeOnly == true {
            filter["completedDate"] = ["$exists": false]
            filter["cancelledDate"] = ["$exists": false]

            switch self.sortBy {
            case .latestStart:
                filter["\(deadlinePrefix)deadlineDate"] = ["$gt": .datetime(Date())]
            case .earliestDeadline:
                // ensure we don't relax the date restriction accidentally
                filter["\(deadlinePrefix)deadlineDate"] = ["$gt": .datetime(max(Date(), dateDelimiter))]
            }
        }
    }

    func makeSortDocument(deadlinePrefix: String = "", startPrefix: String = "") -> BSONDocument {
        switch self.sortBy {
        case .latestStart:
            return ["\(startPrefix)startDate": -1]
        case .earliestDeadline:
            return ["\(deadlinePrefix)deadlineDate": 1]
        }
    }
}
