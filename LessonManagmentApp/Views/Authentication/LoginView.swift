//
//  LoginView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 10/9/2026.
//

import SwiftUI

struct LoginView: View {
    
    @StateObject var viewModel: LoginViewModel
    
    let onLogin: (User) -> Void

    var body: some View {

        VStack(spacing: 24) {

            Spacer()

            Image("applogo")
                .resizable()
                .scaledToFit()
                .frame(
                    width: 300,
                    height: 300
                )

            Text("Sign in to continue")
                .foregroundStyle(.secondary)

            VStack(spacing: 16) {

                TextField(
                    "Email",
                    text: $viewModel.email
                )
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)

                SecureField(
                    "Password",
                    text: $viewModel.password
                )
                .textFieldStyle(.roundedBorder)
                .submitLabel(.go)
                .onSubmit {
                    login()
                }
            }

            if !viewModel.errorMessage.isEmpty {

                Text(viewModel.errorMessage)
                    .foregroundStyle(.red)
                    .font(.caption)
            }

            Button {

                login()

            } label: {

                Text("Sign In")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
    }

    // attempts to log in and passes the authenticated user back to the parent view
    private func login() {

        if let user =
            viewModel.login() {

            onLogin(user)
        }
    }
}
