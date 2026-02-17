import SwiftUI

struct UserInfoView: View {
    @EnvironmentObject var authService: AuthService
    @State private var displayName: String = ""
    @State private var showChangePassword = false
    @State private var currentPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                ZStack {
                    LinearGradient(
                        colors: [Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.9, green: 0.94, blue: 1.0)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 32) {
                            if let user = authService.currentUser {
                                Image(systemName: "person.crop.circle.fill")
                                    .font(.system(size: 80))
                                    .foregroundStyle(.blue.gradient)
                                    .padding(.top, 32)
                                
                                VStack(alignment: .leading, spacing: 20) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Name")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        TextField("Your name", text: $displayName)
                                            .textContentType(.name)
                                            .textFieldStyle(.roundedBorder)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Email (login)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(user.email)
                                            .font(.body)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Button("Save name") {
                                        authService.updateProfile(name: displayName)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.blue)
                                }
                                .padding(24)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal, 24)
                                
                                if let success = authService.successMessage {
                                    Text(success)
                                        .font(.subheadline)
                                        .foregroundStyle(.green)
                                }
                                if let error = authService.errorMessage {
                                    Text(error)
                                        .font(.subheadline)
                                        .foregroundStyle(.red)
                                }
                                
                                // Change password section
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("Change password")
                                        .font(.headline)
                                    
                                    if showChangePassword {
                                        SecureField("Current password", text: $currentPassword)
                                            .textContentType(.password)
                                            .textFieldStyle(.roundedBorder)
                                        SecureField("New password (min 6 characters)", text: $newPassword)
                                            .textContentType(.newPassword)
                                            .textFieldStyle(.roundedBorder)
                                        SecureField("Confirm new password", text: $confirmNewPassword)
                                            .textContentType(.newPassword)
                                            .textFieldStyle(.roundedBorder)
                                        
                                        HStack(spacing: 12) {
                                            Button("Update password") {
                                                guard newPassword == confirmNewPassword else {
                                                    authService.errorMessage = "New passwords do not match."
                                                    return
                                                }
                                                if authService.changePassword(currentPassword: currentPassword, newPassword: newPassword) {
                                                    currentPassword = ""
                                                    newPassword = ""
                                                    confirmNewPassword = ""
                                                    showChangePassword = false
                                                }
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .tint(.blue)
                                            
                                            Button("Cancel") {
                                                showChangePassword = false
                                                currentPassword = ""
                                                newPassword = ""
                                                confirmNewPassword = ""
                                                authService.clearMessages()
                                            }
                                            .foregroundStyle(.secondary)
                                        }
                                    } else {
                                        Button("Change password") {
                                            showChangePassword = true
                                            authService.clearMessages()
                                        }
                                        .foregroundStyle(.blue)
                                    }
                                }
                                .padding(24)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                .padding(.horizontal, 24)
                            }
                            
                            Spacer(minLength: 24)
                            
                            Button("Log out", role: .destructive) {
                                authService.logOut()
                            }
                            .padding(.bottom, 32)
                        }
                    }
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .onAppear {
                    displayName = authService.currentUser?.name ?? ""
                }
                .onChange(of: authService.currentUser?.name) { name in
                    if let name { displayName = name }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    UserInfoView()
        .environmentObject(AuthService.shared)
}
