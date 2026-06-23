import SwiftUI

struct ConversationRowView: View {
    let conversation: Conversation

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            avatarSection

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    Text(conversation.title)
                        .font(.custom("IntelOneMono-Regular", size: 18))
                        .foregroundColor(.appForeground)
                        .lineLimit(1)

                    Spacer()

                    Text(conversation.status)
                        .font(.custom("IntelOneMono-Regular", size: 12))
                        .foregroundColor(.appForeground.opacity(0.9))
                }

                Text(conversation.subtitle)
                    .font(.custom("IntelOneMono-Regular", size: 13))
                    .foregroundColor(.appForeground.opacity(0.9))

                Text(conversation.preview)
                    .font(.custom("IntelOneMono-Light", size: 13))
                    .foregroundColor(.appForeground.opacity(0.88))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)
        )
    }

    @ViewBuilder
    private var avatarSection: some View {
        if conversation.isGroup {
            ZStack {
                Circle()
                    .fill(Color.appForeground)
                    .frame(width: 56, height: 56)
                    .offset(x: -18)

                Circle()
                    .fill(Color.appForeground.opacity(0.95))
                    .frame(width: 56, height: 56)

                Circle()
                    .fill(Color.appForeground.opacity(0.92))
                    .frame(width: 56, height: 56)
                    .overlay {
                        Text("+3")
                            .font(.custom("IntelOneMono-Regular", size: 15))
                            .foregroundColor(.appBackground)
                            .offset(x: 18)
                    }
                    .offset(x: 18)
            }
            .frame(width: 92, height: 64)
        } else {
            Circle()
                .fill(Color.appForeground)
                .frame(width: 66, height: 66)
        }
    }
}
