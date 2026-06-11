import SwiftUI

@main
struct SecureChatApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            AppRouter()
                .environmentObject(authViewModel)
        }
    }
}
