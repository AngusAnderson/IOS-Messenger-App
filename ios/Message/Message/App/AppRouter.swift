import SwiftUI

struct AppRouter: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isRestoringSession {
                ZStack {
                    Color.black.ignoresSafeArea()

                    VStack(spacing: 16) {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(1.2)

                        Text("Restoring session...")
                            .foregroundColor(.white.opacity(0.85))
                            .font(.headline)
                    }
                }
            } else if authViewModel.isAuthenticated {
                NavigationStack {
                    ChatListView()
                }
            } else {
                NavigationStack {
                    LoginView()
                }
            }
        }
    }
}
