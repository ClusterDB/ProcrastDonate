import MongoDBVapor
import Vapor

/// Handlers for /users/<userid>/sponsorships route
enum UserSponsorships {
    /// GET handler.
    /// Returns an array containing the user's sponsorships.
    static func get(userID: BSONObjectID, req: Request) throws -> EventLoopFuture<[SponsorshipContent]> {
        let queryOptions = try req.query.decode(QueryOptions.self)
        var filterDoc: BSONDocument = [:]
        try queryOptions.updateFilter(&filterDoc, deadlinePrefix: "task.")

        let pipeline: [BSONDocument] = [
            ["$match": ["sponsor": .objectID(userID)]],
            [
                "$lookup": [
                    "from": .string(req.tasks.name),
                    "localField": "task",
                    "foreignField": "_id",
                    "as": "task",
                ],
            ],
            ["$unwind": "$task"],
            ["$match": .document(filterDoc)],
            ["$sort": .document(queryOptions.makeSortDocument(deadlinePrefix: "task."))],
        ]
        return req.sponsorships.aggregate(pipeline, withOutputType: SponsorshipContent.self).flatMap { $0.toArray() }
    }
}

extension BSONDocument: Content {}
