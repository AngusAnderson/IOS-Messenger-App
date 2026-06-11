import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        Group {
            if viewModel.didSendCode {
                EmailOTPView()
            } else {
                EmailEntryView()
            }
        }
        .navigationTitle("Sign In")
    }
}

private struct EmailEntryView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Sign in with your email")
                .font(.title2)
                .fontWeight(.semibold)

            Text("We'll send you a 6-digit login code.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            TextField(
                "Email address",
                text: Binding(
                    get: { viewModel.email },
                    set: { viewModel.email = $0 }
                )
            )
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            .autocorrectionDisabled(true)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            if let info = viewModel.infoMessage {
                Text(info)
                    .foregroundStyle(.green)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await viewModel.requestCode()
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Send Code")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isLoading)

            Spacer()
        }
        .padding()
    }
}

private struct EmailOTPView: View {
    @EnvironmentObject var viewModel: AuthViewModel

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("Enter your code")
                .font(.title2)
                .fontWeight(.semibold)

            Text("We sent a 6-digit code to \(viewModel.email)")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            TextField(
                "6-digit code",
                text: Binding(
                    get: { viewModel.code },
                    set: { viewModel.code = $0 }
                )
            )
            .keyboardType(.numberPad)
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .font(.footnote)
                    .multilineTextAlignment(.center)
            }

            Button {
                Task {
                    await viewModel.verifyCode()
                }
            } label: {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Verify Code")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(viewModel.isLoading)

            Button("Use another email") {
                viewModel.code = ""
                viewModel.didSendCode = false
                viewModel.errorMessage = nil
                viewModel.infoMessage = nil
            }
            .padding(.top, 8)

            Spacer()
        }
        .padding()
    }
}
