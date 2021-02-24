import Foundation
import FoundationNetworking
import MongoSwiftSync
import SwiftBSON

let dateFormatter: ISO8601DateFormatter = {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return formatter
}()

guard let connectionString = ProcessInfo.processInfo.environment["PROCRASTDONATE_DB_URI"] else {
    fatalError("no MongoDB connection string provided in PROCRSATDONATE_DB_URI environment variable")
}

let client = try MongoClient(connectionString)

let db = client.db("dev")

let tasks = db.collection("task")
let users = db.collection("user")
let charities = db.collection("charity")
let sponsorships = db.collection("sponsorship")

let userID = BSON.objectID(try BSONObjectID("60355415865cbf06d56935d8"))
let charityID = BSON.objectID()

try getSponsorships()

func getSponsorships() throws {
    try populate()

    let url = URL(string: "http://127.0.0.1:8080/users/60355415865cbf06d56935d8/sponsorships?sort-by=latest-start")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    let session = URLSession.shared
    let task = session.dataTask(with: request) { data, response, error in
        if let error = error {
            print("got error: \(error)")
            return
        }

        guard let response = response as? HTTPURLResponse else {
            print("no response")
            return
        }

        print("got response status code: \(response.statusCode)")
        if
            let mimeType = response.mimeType,
            mimeType == "application/json",
            let data = data,
            let dataString = data.prettyPrintedJSONString
        {
            print(dataString)
        }
    }
    task.resume()
    sleep(5)
}

/// Use the REST API to create a new task.
func newTask() throws {
    try populate()

    print("creating new task...")
    let newTask: BSONDocument = [
        "title": "My new task",
        "descriptionText": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "deadlineDate": .datetime(Date().advanced(by: 10000)),
        "donationAmount": [
            "amount": 10000, // $10
            "currency": "USD",
        ],
        "donationOnFailure": false,
        "charity": charityID,
        "tags": ["post", "usd"],
    ]

    let url = URL(string: "http://127.0.0.1:8080/users/60355415865cbf06d56935d8/tasks")!
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    let data = try ExtendedJSONEncoder().encode(newTask)

    let session = URLSession.shared
    let task = session.uploadTask(with: request, from: data) { data, response, error in
        if let error = error {
            print("got error: \(error)")
            return
        }

        guard let response = response as? HTTPURLResponse else {
            print("no response")
            return
        }

        print("got response status code: \(response.statusCode)")
        if
            let mimeType = response.mimeType,
            mimeType == "application/json",
            let data = data,
            let dataString = data.prettyPrintedJSONString
        {
            print(dataString)
        }
    }
    task.resume()
    sleep(5)
}

/// Populate sample data into the db. This drops the existing collections first.
func populate() throws {
    print("dropping old collections...")
    try tasks.drop()
    try users.drop()
    try charities.drop()

    let now = Date()
    print((["d": .datetime(now)] as BSONDocument).toExtendedJSONString())

    let user: BSONDocument = [
        "_id": userID,
        "username": "test_user",
        "displayName": "John Doe",
        "email": "test@test.com",
        "password": "TBD HASH ALGO",
        "bio": "Hi, I'm John Doe",
        "friends": [],
    ]

    let charity: BSONDocument = [
        "_id": charityID,
        "name": "demo charity",
        "descriptionText": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "website": "www.mongodb.com",
    ]

    let taskID = BSON.objectID()
    let task: BSONDocument = [
        "_id": taskID,
        "title": "generic todo item",
        "user": userID,
        "descriptionText": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "startDate": .datetime(Date().advanced(by: -100)),
        "renewals": [],
        "deadlineDate": .datetime(Date().advanced(by: 10000)),
        "donationAmount": ["amount": 1000, "currency": "USD"],
        "donateOnFailure": true,
        "charity": charityID,
        "tags": ["debug", "fun", "difficult"],
    ]

    let completedTask: BSONDocument = [
        "_id": .objectID(),
        "title": "a second generic todo item",
        "user": userID,
        "descriptionText": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
        "startDate": .datetime(Date().advanced(by: -50)),
        "renewals": [],
        "deadlineDate": .datetime(Date().advanced(by: 8000)),
        "completedDate": .datetime(Date().advanced(by: 5000)),
        "donationAmount": ["amount": 1000, "currency": "USD"],
        "donateOnFailure": true,
        "charity": charityID,
        "tags": ["completed"],
    ]

    let sponsorship: BSONDocument = [
        "_id": .objectID(),
        "task": taskID,
        "sponsor": userID,
        "comment": "you can do it!",
        "donationAmount": [
            "amount": 500,
            "currency": "USD",
        ],
        "startDate": .datetime(Date()),
        "settled": false,
    ]

    print("inserting...")
    try charities.insertOne(charity)
    try users.insertOne(user)
    try tasks.insertOne(task)
    try tasks.insertOne(completedTask)
    try sponsorships.insertOne(sponsorship)
    print("done!")
}

extension Data {
    /// From: https://gist.github.com/cprovatas/5c9f51813bc784ef1d7fcbfb89de74fe
    var prettyPrintedJSONString: NSString? { /// NSString gives us a nice sanitized debugDescription
        guard
            let object = try? JSONSerialization.jsonObject(with: self, options: []),
            let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
            let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
        else {
            return nil
        }
        return prettyPrintedString
    }
}
