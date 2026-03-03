import SwiftUI

/// Second view: shown after login/register.
struct HomeView: View {
    @Binding var isLoggedIn: Bool
    let username: String
    @Binding var password: String

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                VStack {
                    Text("Home")
                        .font(.title)
                    Text("You're in. Keep this view minimal and add features as needed.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding()

                    Spacer()

                    Button("Log Out") {
                        isLoggedIn = false
                    }
                    .buttonStyle(.bordered)
                    .padding(.bottom, 32)
                }
                .padding()
                .navigationTitle("Home")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        NavigationLink("Profile") {
                            ProfileView(username: username, password: $password)
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

#Preview {
    HomeView(isLoggedIn: .constant(true), username: "user@example.com", password: .constant(""))
}
