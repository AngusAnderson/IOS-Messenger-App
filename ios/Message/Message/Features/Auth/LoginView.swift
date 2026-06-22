import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var keyboardHeight: CGFloat = 0

    var body: some View {
        ZStack {
            LoginBackgroundView()

            VStack {
                Spacer()

                if viewModel.didSendCode {
                    CodeCardView()
                } else {
                    EmailCardView()
                }
            }
            .padding(.bottom, keyboardHeight > 0 ? 220 : -5)
            .padding(.horizontal, 20)
            .animation(.easeInOut(duration: 0.25), value: keyboardHeight)
        }
        .ignoresSafeArea()
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            guard
                let userInfo = notification.userInfo,
                let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
            else { return }

            keyboardHeight = keyboardFrame.height
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            keyboardHeight = 0
        }
    }
}

private struct LoginBackgroundView: View {
    var body: some View {
        GeometryReader { geometry in
            Image("tower-bg")
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width)
                .clipped()
                .ignoresSafeArea()
        }
    }
}

// First page where the user enters their email

private struct EmailCardView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text("XXIV")
                .font(.custom("IntelOneMono-Regular", size: 20))
                .foregroundColor(.white)

            Text("Use your email to receive a one-time code.")
                .font(.custom("IntelOneMono-Light", size: 13))
                .foregroundColor(.white.opacity(0.85))

            TextField(
                "",
                text: Binding(
                    get: { viewModel.email },
                    set: { viewModel.email = $0 }
                ),
                prompt: Text("Email...")
                    .font(.custom("IntelOneMono-Regular", size: 16))
                    .foregroundColor(.white.opacity(0.65))
            )
            .font(.custom("IntelOneMono-Regular", size: 13))
            .foregroundColor(.white)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .autocorrectionDisabled(true)
            .padding(.horizontal, 18)
            .frame(height: 52)
            .background(Color.white.opacity(0.06))
            .overlay(
                Rectangle()
                    .stroke(
                        Color.white.opacity(0.35),
                        lineWidth: 1
                    )
            )

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.custom("IntelOneMono-Regular", size: 13))
                    .foregroundColor(.red)
            }

            if let info = viewModel.infoMessage {
                Text(info)
                    .font(.custom("IntelOneMono-Regular", size: 13))
                    .foregroundColor(.white.opacity(0.8))
            }

            HStack {
                Spacer()

                Button {
                    Task {
                        await viewModel.requestCode()
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(
                                Color(hex: 0x8E0320)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        Color.black,
                                        lineWidth: 2
                                    )
                            )

                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Send Code")
                                .font(.custom("IntelOneMono-Regular", size: 16))
                                .foregroundColor(Color(hex: 0xF4E7DB))
                        }
                    }
                    .frame(width: 180, height: 58)
                }
                .disabled(viewModel.isLoading)

                Spacer()
            }
            .padding(.top, 18)
        }
        .padding(20)
        .padding(.bottom, 80)
        .background(
            RoundedRectangle(cornerRadius: 0)
                .fill(.ultraThinMaterial.opacity(0.75))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(
                    Color.white.opacity(0.35),
                    lineWidth: 1
                )
        )
    }
}

// Second Page where we enter the code

private struct CodeCardView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text("Enter the code")
                .font(.custom("IntelOneMono-Regular", size: 18))
                .foregroundColor(.white)

            Text("Sent to \(viewModel.email)")
                .font(.custom("IntelOneMono-Regular", size: 12))
                .foregroundColor(.white.opacity(0.85))

            TextField(
                "",
                text: Binding(
                    get: { viewModel.code },
                    set: { viewModel.code = $0 }
                ),
                prompt: Text("Code...")
                    .font(.custom("IntelOneMono-Regular", size: 16))
                    .foregroundColor(.white.opacity(0.65))
            )
            .font(.custom("IntelOneMono-Regular", size: 16))
            .foregroundColor(.white)
            .keyboardType(.numberPad)
            .padding(.horizontal, 18)
            .frame(height: 52)
            .background(Color.white.opacity(0.06))
            .overlay(
                Rectangle()
                    .stroke(
                        Color.white.opacity(0.35),
                        lineWidth: 1
                    )
            )

            if let error = viewModel.errorMessage {
                Text(error)
                    .font(.custom("IntelOneMono-Regular", size: 13))
                    .foregroundColor(.red)
            }

            HStack(spacing: 12) {

                Button {
                    viewModel.code = ""
                    viewModel.didSendCode = false
                    viewModel.errorMessage = nil
                    viewModel.infoMessage = nil
                } label: {
                    Text("Back")
                        .font(.custom("IntelOneMono-Regular", size: 15))
                        .foregroundColor(.white)
                        .frame(width: 110, height: 52)
                        .background(Color.white.opacity(0.08))
                        .overlay(
                            Rectangle()
                                .stroke(
                                    Color.white.opacity(0.3),
                                    lineWidth: 1
                                )
                        )
                }

                Spacer()

                Button {
                    Task {
                        await viewModel.verifyCode()
                    }
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color(hex: 0x8E0320))
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(
                                        Color.black,
                                        lineWidth: 2
                                    )
                            )

                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Enter")
                                .font(.custom("IntelOneMono-Regular", size: 18))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 180, height: 52)
                }
                .disabled(viewModel.isLoading)
            }
            .padding(.top, 18)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    Color.white.opacity(0.35),
                    lineWidth: 1
                )
        )
    }
}
