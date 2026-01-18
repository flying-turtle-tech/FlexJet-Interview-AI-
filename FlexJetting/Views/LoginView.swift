import SwiftUI
import Combine

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel

    init(authState: AuthState) {
        _viewModel = StateObject(wrappedValue: LoginViewModel(authState: authState))
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("FlexJetting")
                .font(.largeTitle)
                .fontWeight(.bold)

            VStack(spacing: 16) {
                TextField("Username", text: $viewModel.username)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.username)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()

                SecureField("Password", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.password)
            }
            .padding(.horizontal, 32)

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.callout)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                Task {
                    await viewModel.signIn()
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                } else {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }
}
