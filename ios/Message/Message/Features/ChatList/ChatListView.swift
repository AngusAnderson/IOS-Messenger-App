import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                if let user = authViewModel.currentUser {
                    Text("Welcome, \(user.username)")
                        .font(.title2)
                        .foregroundColor(.white)
                }

                Text("Chat List")
                    .font(.title)
                    .foregroundColor(.white)

                Button("Log Out") {
                    authViewModel.logout()
                }
                .padding()
                .background(Color.red.opacity(0.85))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding()
        }
    }
}
