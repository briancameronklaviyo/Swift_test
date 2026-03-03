import SwiftUI

/// First screen: simple Login / Register. No backend; tapping Continue sets isLoggedIn and stores username/password.
struct LoginRegisterView: View {
    @Binding var isLoggedIn: Bool
    @Binding var username: String
    @Binding var password: String
    @State private var mode: AuthMode = .login
    @State private var email = ""
    @State private var inputPassword = ""

    enum AuthMode: String, CaseIterable {
        case login = "Login"
        case register = "Register"
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack(spacing: 20) {
                    Picker("Mode", selection: $mode) {
                        ForEach(AuthMode.allCases, id: \.self) { Text($0.rawValue).tag($0) }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    TextField("Email", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    SecureField("Password", text: $inputPassword)
                        .textFieldStyle(.roundedBorder)
                    
                    Button(mode == .login ? "Log In" : "Register") {
                        username = email
                        password = inputPassword
                        isLoggedIn = true
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                    
                    Spacer()
                }
                .padding()
                .navigationTitle(mode == .login ? "Log In" : "Register")
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    LoginRegisterView(isLoggedIn: .constant(false), username: .constant(""), password: .constant(""))
}
