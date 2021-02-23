import Vapor
import MongoDBVapor

struct MyError: Error {}

extension Request {
    var db: MongoDatabase {
        self.mongoDB.client.db("dev")
    }
    var tasks: MongoCollection<Task> {
        self.db.collection("task", withType: Task.self)
    }
}

func routes(_ app: Application) throws {
    app.get { req in
        return "It works!"
    }

    app.get("users", ":userid", "tasks") { req -> EventLoopFuture<[Task]> in
        let userID = try BSONObjectID(req.parameters.get("userid")!)
        return req.tasks.find(["user": .objectID(userID)]).flatMap { cursor in
            cursor.toArray()
        }
    }
}
