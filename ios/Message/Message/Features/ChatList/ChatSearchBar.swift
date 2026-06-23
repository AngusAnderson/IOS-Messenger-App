import SwiftUI

struct ChatSearchBar: View {
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.cardBackground)
                .shadow(color: .black.opacity(0.35), radius: 10, x: 0, y: 6)

            TextField(
                "",
                text: $text,
                prompt: Text("Search...")
                    .foregroundColor(Color.appForeground.opacity(0.5))
            )
            .textFieldStyle(.plain)
            .font(.custom("IntelOneMono-Regular", size: 18))
            .foregroundColor(.appForeground)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .padding(.horizontal, 16)
        }
        .frame(height: 58)
    }
}
