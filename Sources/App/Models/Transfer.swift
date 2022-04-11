import Fluent
import Vapor

enum TransferType {
    static let msgType = "message"
    static let fileType = "file"
}

final class Transfer: Model, Content {
    static var schema: String = "transfers"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "type")
    var type: String

    @Field(key: "content")
    var content: String

    @Field(key: "isimage")
    var isImage: Bool

    @Field(key: "name")
    var name: String?

    init() {}

    init(id: UUID? = nil, type: String, content: String, isImage: Bool = false, name: String? = nil) {
        self.id = id
        self.type = type
        self.content = content
        self.isImage = isImage
        self.name = name
    }
}

struct NewTransfer: Content {
    var message: String?
    var file: File?
}

struct TransferParam: Encodable {
    var transfers: [Transfer]
    var hideInput: Bool

    init(transfers:[Transfer], hideInput:Bool = false) {
        self.transfers = transfers
        self.hideInput = hideInput
    }
}