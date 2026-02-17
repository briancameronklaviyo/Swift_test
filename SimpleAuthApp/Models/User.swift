import Foundation

struct User: Codable, Identifiable {
    let id: UUID
    var name: String
    var email: String
    var passwordHash: String
    var salt: String
    
    init(id: UUID = UUID(), name: String, email: String, passwordHash: String, salt: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
        self.salt = salt
    }
}
