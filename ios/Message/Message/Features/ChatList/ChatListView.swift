import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ChatListViewModel()

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    ChatSearchBar(text: $viewModel.searchText)

                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.appForeground)
                            .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 18) {
                            ForEach(viewModel.filteredConversations) { conversation in
                                NavigationLink(value: conversation) {
                                    ConversationRowView(conversation: conversation)
                                }
                                .buttonStyle(.plain)
                            }
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
        .navigationDestination(for: Conversation.self) { conversation in
            ChatDetailView(conversation: conversation)
        }
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
        .task {
            await viewModel.loadConversations()
        }
    }
}
