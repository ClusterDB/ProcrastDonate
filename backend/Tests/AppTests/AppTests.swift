@testable import App
import MongoDBVapor
import Vapor
import XCTVapor

final class AppTests: XCTestCase {
    static let userID = BSON.objectID(try! BSONObjectID("60355415865cbf06d56935d8"))
    static let userID1 = BSON.objectID()
    static let taskID = BSON.objectID()
    static let completedTaskID = BSON.objectID()
    static let charityID = BSON.objectID()
    static let formatter = ISO8601DateFormatter()
    static let startDate = Date()

    static func makeTestClient(using elg: EventLoopGroup) throws -> MongoClient {
        guard let uri = ProcessInfo.processInfo.environment["PROCRASTDONATE_DB_URI"] else {
            fatalError("no uri")
        }

        return try MongoClient(uri, using: elg)
    }

    static func populate(using client: MongoClient) throws {
        let db = client.db("dev")

        let tasks = db.collection("task")
        let users = db.collection("user")
        let charities = db.collection("charity")
        let sponsorships = db.collection("sponsorship")

        try tasks.drop().wait()
        try users.drop().wait()
        try charities.drop().wait()
        try sponsorships.drop().wait()

        let user: BSONDocument = [
            "_id": userID,
            "username": "test_user",
            "displayName": "John Doe",
            "email": "test@test.com",
            "password": "TBD HASH ALGO",
            "bio": "Hi, I'm John Doe",
            "friends": [],
        ]

        let user1: BSONDocument = [
            "_id": userID1,
            "username": "other_user",
            "displayName": "Jane Doe",
            "email": "other@test.com",
            "password": "TBD HASH ALGO",
            "bio": "Hi, I'm another user",
            "friends": [],
        ]

        let charity: BSONDocument = [
            "_id": charityID,
            "name": "demo charity",
            "descriptionText": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            "website": "www.mongodb.com",
        ]

        let task: BSONDocument = [
            "_id": taskID,
            "title": "generic todo item",
            "user": userID,
            "descriptionText": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            "startDate": .datetime(Self.startDate.advanced(by: -100)),
            "renewals": [],
            "deadlineDate": .datetime(Self.startDate.advanced(by: 10000)),
            "donationAmount": ["amount": 1000, "currency": "USD"],
            "donateOnFailure": false,
            "charity": self.charityID,
            "tags": ["debug", "fun", "difficult"],
        ]

        let completedTask: BSONDocument = [
            "_id": completedTaskID,
            "title": "a second generic todo item",
            "user": userID,
            "descriptionText": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
            "startDate": .datetime(Self.startDate.advanced(by: -50)),
            "renewals": [],
            "deadlineDate": .datetime(Self.startDate.advanced(by: 8000)),
            "completedDate": .datetime(Self.startDate.advanced(by: 5000)),
            "donationAmount": ["amount": 1000, "currency": "USD"],
            "donateOnFailure": true,
            "charity": self.charityID,
            "tags": ["completed"],
        ]

        let sponsorship: BSONDocument = [
            "_id": .objectID(),
            "task": taskID,
            "sponsor": userID1,
            "comment": "you can do it!",
            "donationAmount": [
                "amount": 500,
                "currency": "USD",
            ],
            "startDate": .datetime(Self.startDate),
            "settled": false,
        ]

        let earlierSponsorship: BSONDocument = [
            "_id": .objectID(),
            "task": completedTaskID,
            "sponsor": userID1,
            "comment": "you can do it too!",
            "donationAmount": [
                "amount": 500,
                "currency": "USD",
            ],
            "startDate": .datetime(Self.startDate.advanced(by: -100)),
            "settled": false,
        ]

        _ = try charities.insertOne(charity).wait()
        _ = try users.insertOne(user).wait()
        _ = try users.insertOne(user1).wait()
        _ = try tasks.insertOne(task).wait()
        _ = try tasks.insertOne(completedTask).wait()
        _ = try sponsorships.insertOne(sponsorship).wait()
        _ = try sponsorships.insertOne(earlierSponsorship).wait()
    }

    func testUserTaskPost() throws {
        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 4)

        // populate db
        let client = try AppTests.makeTestClient(using: elg)
        defer {
            try? client.syncClose()
        }
        try AppTests.populate(using: client)

        let app = Application(.testing, .shared(elg))
        defer {
            app.mongoDB.cleanup()
            app.shutdown()
        }
        try configure(app)

        let baseURI = "users/\(AppTests.userID.objectIDValue!.hex)/tasks?"

        try app.test(.GET, baseURI + "sort-by=earliest-deadline") { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([Task].self)
            XCTAssertEqual(results.count, 2)

            let newTask = UserTasks.NewTask(
                _id: BSONObjectID(),
                title: "Some new Task",
                descriptionText: "lorem ipsum",
                deadlineDate: Date().advanced(by: 500),
                donationAmount: MonetaryValue(dollars: 2, cents: 50),
                donateOnFailure: false,
                charity: AppTests.charityID.objectIDValue!,
                tags: ["from", "post"]
            )
            let beforeRequest = { (req: inout XCTHTTPRequest) in
                try req.content.encode(newTask)
            }

            try app.test(.POST, baseURI, beforeRequest: beforeRequest) { res in
                XCTAssertEqual(res.status, .ok)
                try app.test(.GET, baseURI + "sort-by=earliest-deadline") { res in
                    XCTAssertEqual(res.status, .ok)
                    let results = try res.content.decode([Task].self)
                    XCTAssertEqual(results.count, 3)
                    XCTAssertEqual(results[0]._id, newTask._id)
                    XCTAssertEqual(results[0].title, newTask.title)
                    XCTAssertEqual(results[0].donationAmount, newTask.donationAmount)
                }
            }
        }
    }

    func testUserTasksGet() throws {
        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 4)

        // populate db
        let client = try AppTests.makeTestClient(using: elg)
        defer {
            try? client.syncClose()
        }
        try AppTests.populate(using: client)

        let app = Application(.testing, .shared(elg))
        defer {
            app.mongoDB.cleanup()
            app.shutdown()
        }
        try configure(app)

        let baseURI = "users/\(AppTests.userID.objectIDValue!.hex)/tasks?"

        try app.test(.GET, baseURI + "sort-by=earliest-deadline") { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([Task].self)
            XCTAssertEqual(results.count, 2)

            XCTAssertLessThan(results[0].deadlineDate, results[1].deadlineDate)
        }

        try app.test(.GET, baseURI + "sort-by=latest-start") { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([Task].self)
            XCTAssertEqual(results.count, 2)

            XCTAssertGreaterThan(results[0].startDate, results[1].startDate)
        }

        let latestActive = baseURI + "sort-by=latest-start&active-only=true"
        try app.test(.GET, latestActive) { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([Task].self)
            XCTAssertEqual(results.count, 1)

            XCTAssertGreaterThan(results[0].deadlineDate, Date())
        }

        try app.test(.GET, baseURI + "sort-by=earliest-deadline&active-only=true") { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([Task].self)
            XCTAssertEqual(results.count, 1)

            XCTAssertGreaterThan(results[0].deadlineDate, Date())
        }

        let farAwayDate = Self.formatter.string(from: Date.distantFuture)
        try app.test(.GET, baseURI + "sort-by=earliest-deadline&date-delimiter=\(farAwayDate)") { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([Task].self)
            XCTAssertEqual(results.count, 0)
        }

        let mediumFutureDate = Self.startDate.advanced(by: 9000)
        let mediumFuture = Self.formatter.string(from: mediumFutureDate)
        try app.test(.GET, baseURI + "sort-by=earliest-deadline&date-delimiter=\(mediumFuture)") { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([Task].self)
            XCTAssertEqual(results.count, 1)
            XCTAssertGreaterThan(results[0].deadlineDate, mediumFutureDate)
        }

        let latestNow = baseURI + "sort-by=latest-start&date-delimiter=\(Self.formatter.string(from: Self.startDate))"
        try app.test(.GET, latestNow) { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([Task].self)
            XCTAssertEqual(results.count, 2)
            XCTAssertGreaterThan(results[0].startDate, results[1].startDate)
            XCTAssertLessThan(results[0].startDate, Self.startDate)
            XCTAssertLessThan(results[1].startDate, Self.startDate)
        }

        let mediumPastDate = Self.startDate.advanced(by: -75)
        let mediumPast = Self.formatter.string(from: mediumPastDate)
        try app.test(.GET, baseURI + "sort-by=latest-start&date-delimiter=\(mediumPast)") { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([Task].self)
            XCTAssertEqual(results.count, 1)
            XCTAssertLessThan(results[0].startDate, mediumPastDate)
        }

        let distantPast = Self.formatter.string(from: Date.distantPast)
        try app.test(.GET, baseURI + "sort-by=latest-start&date-delimiter=\(distantPast)") { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([Task].self)
            XCTAssertEqual(results.count, 0)
        }
    }

    func testUserSponsorshipsGet() throws {
        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 4)

        // populate db
        let client = try AppTests.makeTestClient(using: elg)
        defer {
            try? client.syncClose()
        }
        try AppTests.populate(using: client)

        let app = Application(.testing, .shared(elg))
        defer {
            app.mongoDB.cleanup()
            app.shutdown()
        }
        try configure(app)

        let baseURI = "users/\(AppTests.userID1.objectIDValue!.hex)/sponsorships?"

        try app.test(.GET, baseURI + "sort-by=earliest-deadline") { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([SponsorshipContent].self)
            XCTAssertEqual(results.count, 2)

            XCTAssertLessThan(results[0].task.deadlineDate, results[1].task.deadlineDate)
        }

        let mediumFutureDate = Self.startDate.advanced(by: 9000)
        let mediumFuture = Self.formatter.string(from: mediumFutureDate)
        try app.test(.GET, baseURI + "sort-by=earliest-deadline&date-delimiter=\(mediumFuture)") { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([SponsorshipContent].self)
            XCTAssertEqual(results.count, 1)
            XCTAssertGreaterThan(results[0].task.deadlineDate, mediumFutureDate)
        }

        try app.test(.GET, baseURI + "sort-by=latest-start") { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([SponsorshipContent].self)
            XCTAssertEqual(results.count, 2)

            XCTAssertGreaterThan(results[0].startDate, results[1].startDate)
        }

        let mediumPastDate = Self.startDate.advanced(by: -75)
        let mediumPast = Self.formatter.string(from: mediumPastDate)
        try app.test(.GET, baseURI + "sort-by=latest-start&date-delimiter=\(mediumPast)") { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([SponsorshipContent].self)
            XCTAssertEqual(results.count, 1)
            XCTAssertLessThan(results[0].startDate, mediumPastDate)
        }
    }

    func testTaskCompletion() throws {
        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 4)

        // populate db
        let client = try AppTests.makeTestClient(using: elg)
        defer {
            try? client.syncClose()
        }
        try AppTests.populate(using: client)

        let app = Application(.testing, .shared(elg))
        defer {
            app.mongoDB.cleanup()
            app.shutdown()
        }
        try configure(app)

        let baseURI = "tasks/\(AppTests.taskID.objectIDValue!.hex)"
        let baseUserURI = "users/\(AppTests.userID.objectIDValue!.hex)/tasks?"
        let latestActiveTasks = baseUserURI + "sort-by=latest-start&active-only=true"

        // assert that we have an active task
        try app.test(.GET, latestActiveTasks) { res in
            XCTAssertEqual(res.status, .ok)
            let results = try res.content.decode([Task].self)
            XCTAssertEqual(results.count, 1)

            let beforeRequest = { (req: inout XCTHTTPRequest) in
                try req.content.encode(TaskUpdateRequest.markAsCompleted)
            }
            // mark the task as done
            try app.test(.PATCH, baseURI, beforeRequest: beforeRequest) { res in
                XCTAssertEqual(res.status, .ok)

                let result = try res.content.decode(Tasks.TaskCompletionResult.self)
                guard case let .paymentCompleted(record) = result else {
                    XCTFail("expected payment record, got \(result)")
                    return
                }
                XCTAssertEqual(record.donationAmount, MonetaryValue(dollars: 10, cents: 0))
                XCTAssertEqual(record.sponsorships.count, 1)
                XCTAssertEqual(record.sponsorships[0].sponsor._id, Self.userID1.objectIDValue)

                // assert that we have no more active tasks
                try app.test(.GET, latestActiveTasks) { res in
                    XCTAssertEqual(res.status, .ok)
                    let results = try res.content.decode([Task].self)
                    XCTAssertEqual(results.count, 0)
                }

                // assert that marking the task as done again fails
                try app.test(.PATCH, baseURI, beforeRequest: beforeRequest) { res in
                    XCTAssertNotEqual(res.status, .ok)
                }
            }
        }
    }
}
