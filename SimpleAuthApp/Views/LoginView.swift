import SwiftUI

@available(iOS 16.0, *)
struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.9, green: 0.94, blue: 1.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 28) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 70))
                            .foregroundStyle(.blue.gradient)
                            .padding(.top, 48)
                        
                        Text("Welcome back")
                            .font(.title.bold())
                            .foregroundStyle(.primary)
                        
                        VStack(spacing: 16) {
                            TextField("Email", text: $email)
                                .textContentType(.emailAddress)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .textFieldStyle(.roundedBorder)
                                .padding(.horizontal, 24)
                            
                            SecureField("Password", text: $password)
                                .textContentType(.password)
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
                        
                        Button("Log in") {
                            _ = authService.logIn(email: email, password: password)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.blue)
                        .controlSize(.large)
                        .padding(.top, 8)
                        
                        Button("Create an account") {
                            showSignUp = true
                        }
                        .foregroundStyle(.blue)
                        .padding(.top, 16)
                    }
                }
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(authService)
            }
            .onAppear { authService.clearMessages() }
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        LoginView()
            .environmentObject(AuthService.shared)
    } else {
        EmptyView()
    }
}
