import SwiftUI

/// Profile view: shows username and allows changing password.
struct ProfileView: View {
    let username: String
    @Binding var password: String

    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var message: String?
    @State private var isSuccess = false

    var body: some View {
        Form {
            Section("Account") {
                if #available(iOS 16.0, *) {
                    LabeledContent("Username", value: username)
                } else {
                    // Fallback on earlier versions
                }
            }

            Section("Change Password") {
                SecureField("Current password", text: $currentPassword)
                SecureField("New password", text: $newPassword)
                SecureField("Confirm new password", text: $confirmPassword)

                if let message {
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(isSuccess ? .green : .red)
                }

                Button("Change Password") {
                    changePassword()
                }
                .disabled(newPassword.isEmpty || confirmPassword.isEmpty)
            }
        }
        .navigationTitle("Profile")
    }

    private func changePassword() {
        message = nil
        guard currentPassword == password else {
            message = "Current password is incorrect."
            return
        }
        guard newPassword == confirmPassword else {
            message = "New passwords don't match."
            return
        }
        guard newPassword.count >= 6 else {
            message = "New password must be at least 6 characters."
            return
        }
        password = newPassword
        currentPassword = ""
        newPassword = ""
        confirmPassword = ""
        message = "Password updated."
        isSuccess = true
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            ProfileView(username: "user@example.com", password: .constant("oldpass"))
        }
    } else {
        // Fallback on earlier versions
    }
}
