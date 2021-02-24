import Foundation
import MongoDBVapor
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    ContentConfiguration.global.use(encoder: ExtendedJSONEncoder(), for: .json)
    ContentConfiguration.global.use(decoder: ExtendedJSONDecoder(), for: .json)

    guard let connectionString = ProcessInfo.processInfo.environment["PROCRASTDONATE_DB_URI"] else {
        fatalError("no MongoDB connection string provided in PROCRSATDONATE_DB_URI environment variable")
    }

    try app.mongoDB.configure(connectionString)

    // register routes
    try routes(app)
}
