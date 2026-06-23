import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var searchText = ""

    private var filteredConversations: [Conversation] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return Conversation.mockData
        }

        return Conversation.mockData.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.preview.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    ChatSearchBar(text: $searchText)

                    LazyVStack(spacing: 18) {
                        ForEach(filteredConversations) { conversation in
                            ConversationRowView(conversation: conversation)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 18)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Log Out") {
                    authViewModel.logout()
                }
                .foregroundColor(.appForeground)
                .font(.custom("IntelOneMono-Regular", size: 14))
            }
        }
        .toolbarBackground(Color.appBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
    }
}
