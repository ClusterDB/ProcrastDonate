import Foundation
import MongoSwiftSync
import SwiftBSON

guard let password = ProcessInfo.processInfo.environment["PROCRASTDONATE_DB_PASSWORD"] else {
    fatalError("no password")
}

guard let username = ProcessInfo.processInfo.environment["PROCRASTDONATE_DB_USERNAME"] else {
    fatalError("no password")
}

print("username: \(username)")

let client = try MongoClient("mongodb+srv://\(username):\(password)@procrastdonate.sbdbz.mongodb.net")

let db = client.db("dev")

let tasks = db.collection("task")
let users = db.collection("user")
let charities = db.collection("charity")

print("dropping old collections...")
try tasks.drop()
try users.drop()
try charities.drop()

let now = Date()
print((["d": .datetime(now)] as BSONDocument).toExtendedJSONString())

let userID = BSON.objectID(try BSONObjectID("60355415865cbf06d56935d8"))
let user: BSONDocument = [
    "_id": userID, 
    "username": "test_user",
    "displayName": "John Doe",
    "email": "test@test.com",
    "password": "TBD HASH ALGO",
    "bio": "Hi, I'm John Doe",
    "friends": []
]

let charityID = BSON.objectID()
let charity: BSONDocument = [
    "_id": charityID,
    "name": "demo charity",
    "descriptionText": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "website": "www.mongodb.com"
]

let task: BSONDocument = [
    "_id": .objectID(),
    "title": "generic todo item",
    "user": userID,
    "descriptionText": "Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
    "startDate": .datetime(Date().advanced(by: -100)),
    "renewals": [],
    "deadlineDate": .datetime(Date().advanced(by: 10000)),
    "donationAmount": [ "amount": 1000, "currency": "USD" ],
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
    "donationAmount": [ "amount": 1000, "currency": "USD" ],
    "donateOnFailure": true,
    "charity": charityID,
    "tags": ["completed"],
]

print("inserting...")
try charities.insertOne(charity)
try users.insertOne(user)
try tasks.insertOne(task)
try tasks.insertOne(completedTask)
print("done!")
