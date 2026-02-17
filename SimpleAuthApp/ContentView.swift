import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authService: AuthService
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                UserInfoView()
            } else {
                if #available(iOS 16.0, *) {
                    LoginView()
                } else {
                    // Fallback on earlier versions
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: authService.isAuthenticated)
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthService.shared)
}
