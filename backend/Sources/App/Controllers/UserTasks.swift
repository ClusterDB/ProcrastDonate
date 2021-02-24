import Foundation
import MongoDBVapor
import Vapor

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
    let dateDelimeter: Date?

    enum CodingKeys: String, CodingKey {
        case activeOnly = "active-only"
        case limit
        case sortBy = "sort-by"
        case dateDelimeter = "date-delimeter"
    }
}

/// Controller for /users/<username>/tasks route.
internal enum UserTasks {
    /// GET handler.
    /// Returns a list of tasks for the user according to the provided query options.
    static func get(userID: BSONObjectID, req: Request) throws -> EventLoopFuture<[Task]> {
        let queryOptions = try req.query.decode(QueryOptions.self)

        var filter: BSONDocument = [
            "user": .objectID(userID),
        ]
        try queryOptions.updateFilter(&filter)

        var findOptions = FindOptions()
        findOptions.sort = queryOptions.makeSortDocument()

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

    /// The data required to create a new task.
    struct NewTask: Content {
        let title: String
        let descriptionText: String
        let deadlineDate: Date
        let donationAmount: MonetaryValue
        let donationOnFailure: Bool
        let charity: BSONObjectID
        let tags: [String]
    }

    static func post(userID: BSONObjectID, req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let newTask = try req.content.decode(NewTask.self)

        guard newTask.deadlineDate > Date() else {
            throw MyError(description: "Invalid deadline date, must be in the future")
        }

        // ensure both the user and charity exist
        let verifyUser = req.users.findOne(["_id": .objectID(userID)])
            .unwrap(or: MyError(description: "No such user"))
        let verifyCharity = req.charities.findOne(["_id": .objectID(newTask.charity)])
            .unwrap(or: MyError(description: "No such charity"))

        return verifyUser.and(verifyCharity).flatMap { _ in
            let fullTask = Task(
                title: newTask.title,
                user: userID,
                descriptionText: newTask.descriptionText,
                deadlineDate: newTask.deadlineDate,
                donationAmount: newTask.donationAmount,
                donateOnFailure: newTask.donationOnFailure,
                charity: newTask.charity,
                tags: newTask.tags
            )
            return req.tasks.insertOne(fullTask).map { _ in HTTPStatus.ok }
        }
    }
}
