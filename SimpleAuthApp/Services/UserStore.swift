import Foundation
import CryptoKit

enum UserStore {
    private static let fileManager = FileManager.default
    private static let fileName = "users.json"
    
    private static var usersFileURL: URL {
        let dir = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = dir.appendingPathComponent("SimpleAuthApp", isDirectory: true)
        if !fileManager.fileExists(atPath: appDir.path) {
            try? fileManager.createDirectory(at: appDir, withIntermediateDirectories: true)
        }
        return appDir.appendingPathComponent(fileName)
    }
    
    static func loadUsers() -> [User] {
        guard let data = try? Data(contentsOf: usersFileURL),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }
    
    static func saveUsers(_ users: [User]) {
        guard let data = try? JSONEncoder().encode(users) else { return }
        try? data.write(to: usersFileURL)
    }
    
    static func hashPassword(_ password: String, salt: String) -> String {
        let combined = (salt + password).data(using: .utf8)!
        let hash = SHA256.hash(data: combined)
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    static func createUser(name: String, email: String, password: String) -> User? {
        var users = loadUsers()
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedEmail.isEmpty,
              users.first(where: { $0.email.lowercased() == normalizedEmail }) == nil else {
            return nil
        }
        let salt = UUID().uuidString
        let hash = hashPassword(password, salt: salt)
        let user = User(name: name, email: normalizedEmail, passwordHash: hash, salt: salt)
        users.append(user)
        saveUsers(users)
        return user
    }
    
    static func findUser(byEmail email: String) -> User? {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return loadUsers().first { $0.email.lowercased() == normalized }
    }
    
    static func findUser(byId id: UUID) -> User? {
        return loadUsers().first { $0.id == id }
    }
    
    static func verifyPassword(_ password: String, for user: User) -> Bool {
        let hash = hashPassword(password, salt: user.salt)
        return hash == user.passwordHash
    }
    
    static func updateUser(_ user: User) {
        var users = loadUsers()
        guard let index = users.firstIndex(where: { $0.id == user.id }) else { return }
        users[index] = user
        saveUsers(users)
    }
    
    static func updatePassword(userId: UUID, newPassword: String) -> Bool {
        var users = loadUsers()
        guard let index = users.firstIndex(where: { $0.id == userId }) else { return false }
        let salt = UUID().uuidString
        let hash = hashPassword(newPassword, salt: salt)
        users[index].passwordHash = hash
        users[index].salt = salt
        saveUsers(users)
        return true
    }
}
