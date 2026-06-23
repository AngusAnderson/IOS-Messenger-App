import SwiftUI

struct ChatDetailView: View {
    let conversation: Conversation
    let messages: [Message]

    @Environment(\.dismiss) private var dismiss
    @State private var draftMessage = ""
    @GestureState private var dragOffset: CGSize = .zero

    private let bottomAnchorID = "BOTTOM_ANCHOR"

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
                        .onChange(of: messages.count) { _ in
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
                Text("Jeremy")
                    .font(.custom("IntelOneMono-light", size: 13))
                    .foregroundColor(.appForeground)

                Text("United Kingdom")
                    .font(.custom("IntelOneMono-light", size: 10))
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

    private func messageStack(maxBubbleWidth: CGFloat) -> some View {
        VStack(spacing: 28) {
            ForEach(messages) { message in
                messageBubble(message, maxBubbleWidth: maxBubbleWidth)
            }
        }
    }

    @ViewBuilder
    private func messageBubble(_ message: Message, maxBubbleWidth: CGFloat) -> some View {
        HStack {
            if !message.isFromCurrentUser {
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
                Spacer(minLength: 48)

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
            }
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

                if draftMessage.isEmpty {
                    Text("Message")
                        .font(.custom("IntelOneMono-Regular", size: 18))
                        .foregroundColor(.appForeground.opacity(0.72))
                        .padding(.horizontal, 18)
                }

                TextField("", text: $draftMessage)
                    .textFieldStyle(.plain)
                    .font(.custom("IntelOneMono-Regular", size: 18))
                    .foregroundColor(.appForeground)
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
            }
            .frame(height: 54)
        }
    }

    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool) {
        guard !messages.isEmpty else { return }

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
