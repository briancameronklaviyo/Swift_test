import SwiftUI

@main
struct LoginAppApp: App {
    /// Tracks whether the user has completed login/register (barebones: no real auth).
    @State private var isLoggedIn = false
    @State private var username = ""
    @State private var password = ""

    var body: some Scene {
        WindowGroup {
            if isLoggedIn {
                HomeView(isLoggedIn: $isLoggedIn, username: username, password: $password)
            } else {
                LoginRegisterView(isLoggedIn: $isLoggedIn, username: $username, password: $password)
            }
        }
    }
}
