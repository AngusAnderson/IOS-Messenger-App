import SwiftUI

struct AppRouter: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
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
