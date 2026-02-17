import Foundation
import Combine

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    
    private init() {
        if let userIdString = KeychainService.loadSession(),
           let userId = UUID(uuidString: userIdString),
           let user = UserStore.findUser(byId: userId) {
            currentUser = user
            isAuthenticated = true
        } else {
            currentUser = nil
            isAuthenticated = false
        }
    }
    
    func signUp(name: String, email: String, password: String) -> Bool {
        errorMessage = nil
        successMessage = nil
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your name."
            return false
        }
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter your email."
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters."
            return false
        }
        guard let user = UserStore.createUser(name: name, email: email, password: password) else {
            errorMessage = "An account with this email already exists."
            return false
        }
        currentUser = user
        isAuthenticated = KeychainService.saveSession(userId: user.id.uuidString)
        successMessage = "Account created successfully."
        return true
    }
    
    func logIn(email: String, password: String) -> Bool {
        errorMessage = nil
        successMessage = nil
        guard let user = UserStore.findUser(byEmail: email) else {
            errorMessage = "No account found with this email."
            return false
        }
        guard UserStore.verifyPassword(password, for: user) else {
            errorMessage = "Incorrect password."
            return false
        }
        currentUser = user
        isAuthenticated = KeychainService.saveSession(userId: user.id.uuidString)
        successMessage = "Welcome back!"
        return true
    }
    
    func logOut() {
        KeychainService.clearSession()
        currentUser = nil
        isAuthenticated = false
        errorMessage = nil
        successMessage = nil
    }
    
    func updateProfile(name: String) {
        guard var user = currentUser else { return }
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        user.name = trimmed
        UserStore.updateUser(user)
        currentUser = user
        successMessage = "Profile updated."
    }
    
    func changePassword(currentPassword: String, newPassword: String) -> Bool {
        errorMessage = nil
        successMessage = nil
        guard let user = currentUser else { return false }
        guard UserStore.verifyPassword(currentPassword, for: user) else {
            errorMessage = "Current password is incorrect."
            return false
        }
        guard newPassword.count >= 6 else {
            errorMessage = "New password must be at least 6 characters."
            return false
        }
        guard UserStore.updatePassword(userId: user.id, newPassword: newPassword) else {
            errorMessage = "Failed to update password."
            return false
        }
        if let updated = UserStore.findUser(byId: user.id) {
            currentUser = updated
        }
        successMessage = "Password changed successfully."
        return true
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
