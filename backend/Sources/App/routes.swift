import MongoDBVapor
import Vapor

struct MyError: Error {
    let description: String
}

private typealias RequestHandler<T> = (Request) throws -> EventLoopFuture<T>
private typealias UserRequestHandler<T> = (BSONObjectID, Request) throws -> EventLoopFuture<T>
private typealias TaskRequestHandler<T> = (BSONObjectID, Request) throws -> EventLoopFuture<T>

extension Request {
    var db: MongoDatabase {
        let options = MongoDatabaseOptions(writeConcern: .majority)
        return mongoDB.client.db(App.dbName, options: options)
    }

    var tasks: MongoCollection<Task> {
        self.db.collection(App.tasksName, withType: Task.self)
    }

    var users: MongoCollection<User> {
        self.db.collection("user", withType: User.self)
    }

    var charities: MongoCollection<Charity> {
        self.db.collection("charity", withType: Charity.self)
    }

    var sponsorships: MongoCollection<Sponsorship> {
        self.db.collection("sponsorship", withType: Sponsorship.self)
    }
}

private func decorateUserRequestHandler<T>(
    _ f: @escaping UserRequestHandler<T>
) -> RequestHandler<T> {
    func decorated(req: Request) throws -> EventLoopFuture<T> {
        let id = try BSONObjectID(req.parameters.get("userid")!)
        return try f(id, req)
    }
    return decorated
}

private func decorateTaskRequestHandler<T>(
    _ f: @escaping UserRequestHandler<T>
) -> RequestHandler<T> {
    func decorated(req: Request) throws -> EventLoopFuture<T> {
        let id = try BSONObjectID(req.parameters.get("taskid")!)
        return try f(id, req)
    }
    return decorated
}

func routes(_ app: Application) throws {
    app.get { _ in
        "It works!"
    }

    app.get("users", ":userid") { req -> EventLoopFuture<UserContent> in
        let userID = try BSONObjectID(req.parameters.get("userid")!)
        return req.users.findOne(["_id": .objectID(userID)]).flatMapThrowing { dbModel in
            guard let content = dbModel?.toContent() else {
                throw Abort(.notFound)
            }
            return content
        }
    }

    app.get("users", ":userid", "tasks", use: decorateUserRequestHandler(UserTasks.get))
    app.post("users", ":userid", "tasks", use: decorateUserRequestHandler(UserTasks.post))

    app.get("users", ":userid", "sponsorships", use: decorateUserRequestHandler(UserSponsorships.get))
    app.post("users", ":userid", "sponsorships", use: decorateUserRequestHandler(UserSponsorships.post))

    app.patch("tasks", ":taskid", use: decorateTaskRequestHandler(Tasks.patch))
}
