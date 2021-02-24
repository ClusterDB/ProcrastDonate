import Vapor
import MongoDBVapor

struct MyError: Error {
    let description: String
}

extension Request {
    var db: MongoDatabase {
        let options = MongoDatabaseOptions(writeConcern: .majority)
        return self.mongoDB.client.db("dev", options: options)
    }

    var tasks: MongoCollection<Task> {
        self.db.collection("task", withType: Task.self)
    }

    var users: MongoCollection<User> {
        self.db.collection("user", withType: User.self)
    }

    var charities: MongoCollection<Charity> {
        self.db.collection("charity", withType: Charity.self)
    }
}

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
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

    app.get("users", ":userid", "tasks", use: UserTasks.get)
    app.post("users", ":userid", "tasks", use: UserTasks.post)
}
