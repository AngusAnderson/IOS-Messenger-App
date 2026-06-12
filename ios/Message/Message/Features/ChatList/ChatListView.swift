import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 20) {
                if let user = authViewModel.currentUser {
                    Text("Welcome, \(user.email)")
                        .foregroundColor(.white)
                        .font(.title2)
                }

                Text("Chat List")
                    .foregroundColor(.white)
                    .font(.largeTitle)

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
        .navigationTitle("Messages")
    }
}
