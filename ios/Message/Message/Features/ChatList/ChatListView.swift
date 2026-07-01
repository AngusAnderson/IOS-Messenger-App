import SwiftUI

struct ChatListView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: ChatListViewModel

    init(viewModel: ChatListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

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

                    } else if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 14) {
                            Text(errorMessage)
                                .font(.custom("IntelOneMono-Regular", size: 14))
                                .foregroundColor(.appForeground)
                                .multilineTextAlignment(.center)

                            Button("Retry") {
                                Task {
                                    await viewModel.refreshConversations()
                                }
                            }
                            .font(.custom("IntelOneMono-Regular", size: 14))
                            .foregroundColor(.appForeground)
                        }
                        .padding(.top, 40)

                    } else if viewModel.filteredConversations.isEmpty {
                        VStack(spacing: 14) {
                            Image(systemName: "message")
                                .font(.system(size: 28, weight: .regular))
                                .foregroundColor(.appForeground.opacity(0.8))

                            Text(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                 ? "No conversations yet"
                                 : "No matching conversations")
                                .font(.custom("IntelOneMono-Regular", size: 16))
                                .foregroundColor(.appForeground)

                            Text(viewModel.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                 ? "Messages will appear here once a chat is created."
                                 : "Try a different name or keyword.")
                                .font(.custom("IntelOneMono-Regular", size: 13))
                                .foregroundColor(.appForeground.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 72)
                        .padding(.horizontal, 24)

                    } else {
                        LazyVStack(spacing: 18) {
                            ForEach(viewModel.filteredConversations) { conversation in
                                NavigationLink {
                                    ChatDetailView(
                                        viewModel: viewModel.makeDetailViewModel(for: conversation)
                                    )
                                } label: {
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
