import SwiftUI

struct ChatDetailView: View {
    let conversation: Conversation
    let messages: [Message]

    @Environment(\.dismiss) private var dismiss
    @State private var draftMessage = ""

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        profileCard
                            .padding(.top, 8)

                        messageStack
                            .padding(.top, 56)
                            .padding(.horizontal, 24)
                            .padding(.bottom, 120)
                    }
                }
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
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.cardBackground)
                        .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)

                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .light))
                        .foregroundColor(.appForeground)
                }
                .frame(width: 52, height: 52)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
    }

    private var profileCard: some View {
        VStack(spacing: 22) {
            Circle()
                .fill(Color.appForeground)
                .overlay(
                    Circle()
                        .stroke(Color.appBackground.opacity(0.7), lineWidth: 1)
                )
                .frame(width: 96, height: 96)

            VStack(spacing: 12) {
                Text(conversation.title)
                    .font(.custom("IntelOneMono-Regular", size: 20))
                    .foregroundColor(.appForeground)

                Text("United Kingdom")
                    .font(.custom("IntelOneMono-Regular", size: 14))
                    .foregroundColor(.appForeground.opacity(0.95))
                    .tracking(1)
            }
        }
        .frame(width: 235, height: 292)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.chatAccent)
        )
        .frame(maxWidth: .infinity)
    }

    private var messageStack: some View {
        GeometryReader { geo in
            VStack(spacing: 28) {
                ForEach(messages) { message in
                    messageBubble(message, maxBubbleWidth: geo.size.width * 0.68)
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(minHeight: CGFloat(messages.count) * 90)
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
}
