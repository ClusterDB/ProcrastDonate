import Foundation
import Vapor
import MongoDBVapor

let dateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()

struct TaskQueryOptions: Content {
    enum SortBy: String, Codable {
        /// Tasks will be returned in order from earliest deadline to latest, with the date delimiter determining
        /// the earliest possible deadline.
        case earliestDeadline = "earliest-deadline"

        /// Tasks will be returned in order from latest start to earliest (newest to oldest), with the date delimiter
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
    let dateDelimeter: String?

    enum CodingKeys: String, CodingKey {
        case activeOnly = "active-only"
        case limit
        case sortBy = "sort-by"
        case dateDelimeter = "date-delimeter"
    }
}

/// /users/<username>/tasks route handler.
/// Returns a list of tasks for the user according to the provided query options.
func userTasks(req: Request) throws -> EventLoopFuture<[Task]> {
    let queryOptions = try req.query.decode(TaskQueryOptions.self)
    let userID = try BSONObjectID(req.parameters.get("userid")!)
    let startDate = Date()

    // this value will be used as either the latest start date or the earliest deadline, depending on sortBy
    let dateDelimeter: Date
    if let rawDate = queryOptions.dateDelimeter {
        guard let parsed = dateFormatter.date(from: rawDate) else {
            throw MyError(description: "\(rawDate) invalid date str")
        }
        dateDelimeter = parsed
    } else {
        dateDelimeter = startDate
    }

    var filter: BSONDocument = [
        "user": .objectID(userID),
    ]
    let sortDocument: BSONDocument

    switch queryOptions.sortBy {
    case .latestStart:
        guard dateDelimeter <= startDate else {
            throw MyError(description: "when sorting by latestStart, delimeter must be in past")
        }
        filter["startDate"] = ["$lt": .datetime(dateDelimeter)]
        sortDocument = ["startDate": -1]
    case .earliestDeadline:
        guard dateDelimeter >= startDate else {
            throw MyError(description: "when sorting by earliestDeadline, delimeter must be in future")
        }
        filter["deadlineDate"] = ["$gt": .datetime(dateDelimeter)]
        sortDocument = ["deadlineDate": 1]
    }
    print(filter)

    var findOptions = FindOptions()
    findOptions.sort = sortDocument
    
    if queryOptions.activeOnly == true {
        filter["completedDate"] =  ["$exists": false]
        filter["cancelledDate"] =  ["$exists": false]

        switch queryOptions.sortBy {
        case .latestStart:
            filter["deadlineDate"] =  ["$gt": .datetime(Date())]
        case .earliestDeadline:
            // if we're sorting by earliest deadline, filter already guarantees we're only looking at
            // active tasks
            break
        }
    }

    if let limit = queryOptions.limit {
        guard limit > 0 else {
            throw Abort(.notFound)
        }
        findOptions.limit = limit
    }

    return req.tasks.find(filter, options: findOptions).flatMap { cursor in
        cursor.toArray()
    }
}
