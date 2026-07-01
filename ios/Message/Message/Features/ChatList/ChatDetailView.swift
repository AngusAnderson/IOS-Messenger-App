import SwiftUI

struct ChatDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ChatDetailViewModel
    @GestureState private var dragOffset: CGSize = .zero

    @State private var isAtLatest = true
    @State private var hasDoneInitialScroll = false
    @State private var jumpToLatestTrigger = 0

    private let topSentinelID = "TOP_SENTINEL"
    private let latestSentinelID = "LATEST_SENTINEL"

    init(viewModel: ChatDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { outerGeo in
            ZStack(alignment: .bottomTrailing) {
                Color.appBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    profileCard
                        .padding(.top, 16)
                        .padding(.bottom, 24)

                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 18) {
                                Color.clear
                                    .frame(height: 1)
                                    .id(latestSentinelID)
                                    .flippedUpsideDown()
                                    .onAppear {
                                        isAtLatest = true
                                    }
                                    .onDisappear {
                                        isAtLatest = false
                                    }

                                ForEach(messageSections) { section in
                                    VStack(spacing: 16) {
                                        ForEach(section.messages) { message in
                                            messageRow(
                                                message,
                                                maxBubbleWidth: outerGeo.size.width * 0.58
                                            )
                                            .id(message.id)
                                            .flippedUpsideDown()
                                        }

                                        dateSeparator(section.title)
                                            .flippedUpsideDown()
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 96)
                        }
                        .flippedUpsideDown()
                        .scrollBounceBehavior(.basedOnSize)
                        .scrollDismissesKeyboard(.interactively)
                        .onAppear {
                            guard !hasDoneInitialScroll else { return }
                            hasDoneInitialScroll = true

                            DispatchQueue.main.async {
                                proxy.scrollTo(latestSentinelID, anchor: .bottom)
                            }
                        }
                        .onChange(of: viewModel.messages.count) { _, _ in
                            guard isAtLatest else { return }

                            DispatchQueue.main.async {
                                withAnimation(.easeOut(duration: 0.22)) {
                                    proxy.scrollTo(latestSentinelID, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: jumpToLatestTrigger) { _, _ in
                            DispatchQueue.main.async {
                                withAnimation(.easeOut(duration: 0.22)) {
                                    proxy.scrollTo(latestSentinelID, anchor: .bottom)
                                }
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
                                DispatchQueue.main.async {
                                    proxy.scrollTo(latestSentinelID, anchor: .bottom)
                                    isAtLatest = true
                                }
                            }
                        }
                    }
                }
                .offset(x: max(0, dragOffset.width))

                if !isAtLatest {
                    jumpToLatestButton
                        .padding(.trailing, 24)
                        .padding(.bottom, 116)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                        .zIndex(10)
                }
            }
            .safeAreaInset(edge: .bottom) {
                composer
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                    .padding(.bottom, 20)
                    .background(Color.appBackground)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .animation(.easeOut(duration: 0.18), value: isAtLatest)
            .task {
                await viewModel.loadMessages()
            }
        }
    }

    private struct MessageSection: Identifiable {
        let id: Date
        let title: String
        let messages: [Message]
    }

    private var messageSections: [MessageSection] {
        let grouped = Dictionary(grouping: viewModel.messages) { message in
            Calendar.current.startOfDay(for: message.sentAt)
        }

        return grouped
            .map { day, messages in
                MessageSection(
                    id: day,
                    title: ChatDateFormatter.daySeparatorTitle(for: day),
                    messages: messages.sorted { $0.sentAt > $1.sentAt }
                )
            }
            .sorted { $0.id > $1.id }
    }

    private var conversation: Conversation {
        viewModel.conversation
    }

    private var jumpToLatestButton: some View {
        Button {
            jumpToLatestTrigger += 1
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.down")
                    .font(.system(size: 14, weight: .semibold))

                Text("Latest")
                    .font(.custom("IntelOneMono-Regular", size: 13))
            }
            .foregroundColor(.appForeground)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.chatAccent)
                    .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
            )
        }
        .buttonStyle(.plain)
    }

    private var profileCard: some View {
        VStack(spacing: 22) {
            Circle()
                .fill(Color.appForeground)
                .overlay(
                    Circle()
                        .stroke(Color.appBackground.opacity(0.7), lineWidth: 1)
                )
                .frame(width: 60, height: 60)

            VStack(spacing: 12) {
                Text(conversation.title)
                    .font(.custom("IntelOneMono-Light", size: 13))
                    .foregroundColor(.appForeground)

                Text("United Kingdom")
                    .font(.custom("IntelOneMono-Light", size: 10))
                    .foregroundColor(.appForeground.opacity(0.95))
                    .tracking(1)
            }
        }
        .frame(width: 140, height: 170)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.chatAccent)
        )
        .frame(maxWidth: .infinity)
    }

    private func dateSeparator(_ text: String) -> some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.appForeground.opacity(0.18))
                .frame(height: 1)

            Text("\(text)")
                .font(.custom("IntelOneMono-Regular", size: 11))
                .foregroundColor(.appForeground.opacity(0.72))
                .fixedSize()

            Rectangle()
                .fill(Color.appForeground.opacity(0.18))
                .frame(height: 1)
        }
        .padding(.vertical, 6)
    }

    private func messageRow(_ message: Message, maxBubbleWidth: CGFloat) -> some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer(minLength: 48)

                VStack(alignment: .trailing, spacing: 6) {
                    Text(message.text)
                        .font(.custom("IntelOneMono-Regular", size: 15))
                        .foregroundColor(.appForeground)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.chatAccent)
                        )
                        .frame(maxWidth: maxBubbleWidth, alignment: .trailing)

                    Text(statusLine(for: message))
                        .font(.custom("IntelOneMono-Regular", size: 11))
                        .foregroundColor(.appForeground.opacity(0.65))
                }
            } else {
                Text(message.text)
                    .font(.custom("IntelOneMono-Regular", size: 15))
                    .foregroundColor(.appBackground)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.appForeground)
                    )
                    .frame(maxWidth: maxBubbleWidth, alignment: .leading)

                Spacer(minLength: 48)
            }
        }
    }

    private func statusLine(for message: Message) -> String {
        let time = ChatDateFormatter.timeString(from: message.sentAt)

        guard message.isFromCurrentUser else {
            return time
        }

        switch message.status {
        case .sending:
            return "\(time) • Sending"
        case .sent:
            return "\(time) • Sent"
        case .failed:
            return "\(time) • Failed"
        case .none:
            return time
        }
    }

    private var composer: some View {
        HStack(spacing: 16) {
            Button {
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.cardBackground)
                        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)

                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .light))
                        .foregroundColor(.appForeground)
                }
                .frame(width: 54, height: 54)
            }

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.cardBackground)
                    .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)

                if viewModel.draftMessage.isEmpty {
                    Text("Message")
                        .font(.custom("IntelOneMono-Regular", size: 18))
                        .foregroundColor(.appForeground.opacity(0.72))
                        .padding(.horizontal, 18)
                }

                TextField("", text: $viewModel.draftMessage)
                    .textFieldStyle(.plain)
                    .font(.custom("IntelOneMono-Regular", size: 18))
                    .foregroundColor(.appForeground)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .onSubmit {
                        viewModel.sendMessage()
                    }
            }
            .frame(height: 54)

            Button {
                viewModel.sendMessage()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(viewModel.canSendMessage ? Color.chatAccent : Color.cardBackground)
                        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)

                    Image(systemName: "arrow.up")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.appForeground)
                }
                .frame(width: 54, height: 54)
            }
            .disabled(!viewModel.canSendMessage)
        }
    }
}
