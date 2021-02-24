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

    static func post(userID: BSONObjectID, req: Request) throws -> EventLoopFuture<HTTPStatus> {
        let newSponsorship = try req.content.decode(NewSponsorship.self)

        // verify user exists first
        return req.users.findOne(["_id": .objectID(userID)])
            .unwrap(or: MyError(description: "No such user"))
            .flatMap { _ in
                req.tasks.findOne(["_id": .objectID(newSponsorship.task)])
            }.flatMapThrowing { task -> Void in
                guard let task = task, task.isActive else {
                    throw MyError(description: "inactive task")
                }
            }.flatMap { _ -> EventLoopFuture<HTTPStatus> in
                let sponsorship = Sponsorship(from: newSponsorship, sponsor: userID)
                return req.sponsorships.insertOne(sponsorship).map { _ -> HTTPStatus in HTTPStatus.ok }
            }
    }
}

extension BSONDocument: Content {}
