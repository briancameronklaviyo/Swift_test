import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.9, green: 0.94, blue: 1.0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    Text("Create account")
                        .font(.title.bold())
                        .foregroundStyle(.primary)
                        .padding(.top, 24)
                    
                    VStack(spacing: 16) {
                        TextField("Full name", text: $name)
                            .textContentType(.name)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 24)
                        
                        TextField("Email", text: $email)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 24)
                        
                        SecureField("Password (min 6 characters)", text: $password)
                            .textContentType(.newPassword)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 24)
                        
                        SecureField("Confirm password", text: $confirmPassword)
                            .textContentType(.newPassword)
                            .textFieldStyle(.roundedBorder)
                            .padding(.horizontal, 24)
                    }
                    .padding(.vertical, 8)
                    
                    if let error = authService.errorMessage {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Button("Sign up") {
                        guard password == confirmPassword else {
                            authService.errorMessage = "Passwords do not match."
                            return
                        }
                        if authService.signUp(name: name, email: email, password: password) {
                            dismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .controlSize(.large)
                    .padding(.top, 8)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { authService.clearMessages() }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        NavigationStack {
            SignUpView()
                .environmentObject(AuthService.shared)
        }
    } else {
        NavigationView {
            SignUpView()
                .environmentObject(AuthService.shared)
        }
    }
}
