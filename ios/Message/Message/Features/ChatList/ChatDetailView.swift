import SwiftUI

struct ChatDetailView: View {
    let conversation: Conversation

    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ChatDetailViewModel
    @GestureState private var dragOffset: CGSize = .zero

    private let bottomAnchorID = "BOTTOM_ANCHOR"

    init(conversation: Conversation) {
        self.conversation = conversation
        _viewModel = StateObject(
            wrappedValue: ChatDetailViewModel(conversation: conversation)
        )
    }

    var body: some View {
        GeometryReader { outerGeo in
            ZStack {
                Color.appBackground
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    profileCard
                        .padding(.top, 16)
                        .padding(.bottom, 24)

                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                messageStack(maxBubbleWidth: outerGeo.size.width * 0.58)
                                    .padding(.horizontal, 24)
                                    .padding(.bottom, 24)

                                Color.clear
                                    .frame(height: 1)
                                    .id(bottomAnchorID)
                            }
                            .padding(.bottom, 96)
                        }
                        .scrollDisabled(dragOffset.width > 10)
                        .onAppear {
                            scrollToBottom(proxy: proxy, animated: false)
                        }
                        .onChange(of: viewModel.messages.count) { _ in
                            scrollToBottom(proxy: proxy, animated: true)
                        }
                    }
                }
                .offset(x: max(0, dragOffset.width))
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
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 8, coordinateSpace: .local)
                    .updating($dragOffset) { value, state, _ in
                        let startedAtLeftEdge = value.startLocation.x <= 32
                        let horizontal = value.translation.width
                        let vertical = value.translation.height

                        let isRightward = horizontal > 0
                        let withinFortyFiveDegrees = abs(horizontal) >= abs(vertical)

                        if startedAtLeftEdge && isRightward && withinFortyFiveDegrees {
                            state = CGSize(width: horizontal, height: 0)
                        }
                    }
                    .onEnded { value in
                        let startedAtLeftEdge = value.startLocation.x <= 32
                        let horizontal = value.translation.width
                        let vertical = value.translation.height
                        let predictedHorizontal = value.predictedEndTranslation.width
                        let predictedVertical = value.predictedEndTranslation.height

                        let isRightward = horizontal > 0
                        let withinFortyFiveDegreesNow = abs(horizontal) >= abs(vertical)
                        let withinFortyFiveDegreesPredicted = abs(predictedHorizontal) >= abs(predictedVertical)

                        let passedDistance = horizontal > 44
                        let passedMomentum = predictedHorizontal > 90

                        if startedAtLeftEdge &&
                            isRightward &&
                            (withinFortyFiveDegreesNow || withinFortyFiveDegreesPredicted) &&
                            (passedDistance || passedMomentum) {
                            dismiss()
                        }
                    }
            )
        }
    }

    // MARK: - Header card

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

    // MARK: - Messages

    private func messageStack(maxBubbleWidth: CGFloat) -> some View {
        VStack(spacing: 28) {
            ForEach(viewModel.messages) { message in
                messageBubble(message, maxBubbleWidth: maxBubbleWidth)
            }
        }
    }

    @ViewBuilder
    private func messageBubble(_ message: Message, maxBubbleWidth: CGFloat) -> some View {
        HStack {
            if !message.isFromCurrentUser {
                // Incoming
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
            } else {
                // Outgoing
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
            }
        }
    }

    private func statusLine(for message: Message) -> String {
        guard message.isFromCurrentUser else {
            return message.timestamp
        }

        if let status = message.status {
            switch status {
            case .sending:
                return "\(message.timestamp) • Sending"
            case .sent:
                return "\(message.timestamp) • Sent"
            case .failed:
                return "\(message.timestamp) • Failed"
            }
        } else {
            return message.timestamp
        }
    }

    // MARK: - Composer

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

    // MARK: - Scrolling

    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool) {
        guard !viewModel.messages.isEmpty else { return }

        DispatchQueue.main.async {
            if animated {
                withAnimation(.easeOut(duration: 0.25)) {
                    proxy.scrollTo(bottomAnchorID, anchor: .bottom)
                }
            } else {
                proxy.scrollTo(bottomAnchorID, anchor: .bottom)
            }
        }
    }
}
