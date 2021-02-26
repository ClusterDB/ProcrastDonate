import Foundation
import MongoDBVapor
import NIO
import Vapor

let dbName = "dev"
let tasksName = "task"

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    ContentConfiguration.global.use(encoder: ExtendedJSONEncoder(), for: .json)
    ContentConfiguration.global.use(decoder: ExtendedJSONDecoder(), for: .json)
    let urlDecoder = URLEncodedFormDecoder(configuration: .init(dateDecodingStrategy: .iso8601))
    ContentConfiguration.global.use(urlDecoder: urlDecoder)

    guard let connectionString = ProcessInfo.processInfo.environment["PROCRASTDONATE_DB_URI"] else {
        fatalError("no MongoDB connection string provided in PROCRSATDONATE_DB_URI environment variable")
    }

    try app.mongoDB.configure(connectionString)

    // register routes
    try routes(app)

    processExpirations(
        previousStartTime: Date().advanced(by: -60),
        eventLoop: app.eventLoopGroup.next(),
        dbClient: app.mongoDB.client
    )
}

func processExpirations(previousStartTime: Date, eventLoop: EventLoop, dbClient: MongoClient) {
    print("processing expirations...")
    let db = dbClient.db(App.dbName)
    let tasks = db.collection(App.tasksName, withType: Task.self)

    let start = Date()
    let filter: BSONDocument = [
        "deadlineDate": [
            "$lt": .datetime(start),
            "$gt": .datetime(previousStartTime)
        ]
    ]
    tasks.find(filter).flatMap { cursor in
        cursor.toArray()
    }.whenComplete { tasks in
        if case let .success(tasksArr) = tasks {
            for task in tasksArr {
                print("task expired: \(task.title)")
            }
        }
        eventLoop.scheduleTask(in: .seconds(5)) {
            processExpirations(previousStartTime: start, eventLoop: eventLoop, dbClient: dbClient)
        }
    }
}
