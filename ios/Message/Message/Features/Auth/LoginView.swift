import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Text("Login / Register")
                    .font(.system(size: 38, weight: .light, design: .serif))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: 16) {
                    TextField("Username", text: $authViewModel.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .foregroundColor(.white)
                        .cornerRadius(14)

                    SecureField("Password", text: $authViewModel.password)
                        .padding()
                        .background(Color.white.opacity(0.08))
                        .foregroundColor(.white)
                        .cornerRadius(14)

                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red.opacity(0.9))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task {
                            await authViewModel.login()
                        }
                    } label: {
                        if authViewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            Text("Log In")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(Color(red: 0.68, green: 0.0, blue: 0.14))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .disabled(authViewModel.isLoading || authViewModel.username.isEmpty || authViewModel.password.isEmpty)
                    .opacity((authViewModel.isLoading || authViewModel.username.isEmpty || authViewModel.password.isEmpty) ? 0.6 : 1.0)

                    Button {
                        Task {
                            await authViewModel.register()
                        }
                    } label: {
                        Text("Create Account")
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(Color.white.opacity(0.08))
                    .foregroundColor(.white)
                    .cornerRadius(14)
                    .disabled(authViewModel.isLoading || authViewModel.username.isEmpty || authViewModel.password.isEmpty)
                    .opacity((authViewModel.isLoading || authViewModel.username.isEmpty || authViewModel.password.isEmpty) ? 0.6 : 1.0)
                }

                Spacer()
            }
            .padding(24)
        }
    }
}
