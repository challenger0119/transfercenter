import Fluent
import Vapor

func routes(_ app: Application) throws {

    app.routes.defaultMaxBodySize = "100mb"

    app.get { req in
        return req.view.render("index", ["title": "Hello!"])
    }

    app.get("hello") { req -> String in
        return "Hello, world!"
    }

    try app.register(collection: TodoController())
    try app.register(collection: TransferController())
}
