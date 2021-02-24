import Foundation
import MongoDBVapor
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    ContentConfiguration.global.use(encoder: ExtendedJSONEncoder(), for: .json)
    ContentConfiguration.global.use(decoder: ExtendedJSONDecoder(), for: .json)

    guard let password = ProcessInfo.processInfo.environment["PROCRASTDONATE_DB_PASSWORD"] else {
        fatalError("no password")
    }

    guard let username = ProcessInfo.processInfo.environment["PROCRASTDONATE_DB_USERNAME"] else {
        fatalError("no password")
    }

    try app.mongoDB.configure("mongodb+srv://\(username):\(password)@procrastdonate.sbdbz.mongodb.net")

    // register routes
    try routes(app)
}
