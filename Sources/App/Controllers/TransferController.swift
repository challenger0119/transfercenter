import Fluent
import Vapor

struct TransferController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let transfer = routes.grouped("transfer")
        transfer.get(use: index)
        transfer.post("delete", use: delete)
        transfer.post(use: create)
    }

    func index(req: Request) async throws -> View {
        let transfers = try await Transfer.query(on: req.db).all()
        return try await req.view.render("transfer", ["transParam": TransferParam(transfers: transfers.reversed())])
    }

    func create(req: Request) async throws -> Response {
        let newTransfer = try req.content.decode(NewTransfer.self)
        if let file = newTransfer.file {

            let formatter = DateFormatter()
            formatter.dateFormat = "y-m-d-HH-MM-SS-"
            let prefix = formatter.string(from: .init())
            let fileName = prefix + file.filename
            let path = req.application.directory.publicDirectory + fileName
            let isImage = ["png", "jpeg", "jpg", "gif"].contains(file.extension?.lowercased())
    
            try await req.application.fileio.openFile(path: path, 
                                            mode: .write,
                                            flags: .allowFileCreation(posixMode: 0x744),
                                            eventLoop: req.eventLoop)
                                            .flatMap { handle in
                                                req.application.fileio.write(fileHandle: handle,
                                                                                buffer: file.data,
                                                                                eventLoop: req.eventLoop)
                                                                                .flatMapThrowing { _ in
                                                                                    try handle.close()
                                                                                }
                                            }.get()

            let transfer = Transfer(type: TransferType.fileType, content: fileName, isImage: isImage, name: file.filename)
            try await transfer.save(on: req.db)
            return req.redirect(to: "/transfer")
        } else if let msg = newTransfer.message {
            let transfer = Transfer(type: TransferType.msgType, content: msg)
            try await transfer.save(on: req.db)
            return req.redirect(to: "/transfer")
        } else {
            throw Abort(.badRequest)
        }         
    }

    func delete(req: Request) async throws -> Response {
        let transfers = try await Transfer.query(on: req.db).all()
        for tran in transfers {
            if tran.type == TransferType.fileType {
                let url = URL(fileURLWithPath: req.application.directory.publicDirectory + tran.content);
                try FileManager.default.removeItem(at: url)
            }
            try await tran.delete(force: true, on: req.db)
        }
        return req.redirect(to: "/transfer")
    }
}