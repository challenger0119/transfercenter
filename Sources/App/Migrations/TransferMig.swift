import Fluent

struct TransferMig: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("transfers")
            .id()
            .field("title", .string, .required)
            .field("isImage", .bool, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("todos").delete()
    }
}
