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
        let tranfers = try await Transfer.query(on: req.db).all()
        return try await req.view.render("transfer", ["transParam": TransferParam(transfers: tranfers)])
    }

    func create(req: Request) async throws -> View {
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
            return try await req.view.render("transfer", ["transParam": TransferParam(transfers: [transfer], hideInput: true)])
        } else if let msg = newTransfer.message {
            let transfer = Transfer(type: TransferType.msgType, content: msg)
            try await transfer.save(on: req.db)
            return try await req.view.render("transfer", ["transParam": TransferParam(transfers: [transfer], hideInput: true)])
        } else {
            throw Abort(.badRequest)
        }         
    }

    func delete(req: Request) async throws -> HTTPStatus {
        let tranfers = try await Transfer.query(on: req.db).all()
        for tran in tranfers {
            print("deleting \(tran.id?.uuidString ?? "") \(tran.content)")
            try await tran.delete(force: true, on: req.db)
        }
        return .ok
    }
}