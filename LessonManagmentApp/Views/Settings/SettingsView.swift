//
//  SettingsView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 10/9/2026.
//

import SwiftUI

struct SettingsView: View {

    @Binding var showMenu: Bool
    let onLogoTap: () -> Void

    let user: User

    @StateObject var viewModel: SettingsViewModel

    @State private var showProfileSheet = false
    @State private var showChangePasswordSheet = false

    var body: some View {

        ScrollView {

            VStack(
                alignment: .leading,
                spacing: 20
            ) {


                MenuBarView(
                    showMenu: $showMenu,
                    onLogoTap: onLogoTap
                )


                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)


                Text("Account")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)


                Button {

                    showProfileSheet = true

                } label: {

                    HStack(spacing: 14) {

                        Image(
                            systemName: "person.circle"
                        )
                        .font(.title3)
                        .frame(
                            width: 36,
                            height: 36
                        )
                        .background(
                            .blue.opacity(0.10)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 9
                            )
                        )

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text("Profile")
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            Text(
                                "View your account details"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(
                            systemName: "chevron.right"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(
                        .gray.opacity(0.10)
                    )
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)


                Button {

                    showChangePasswordSheet = true

                } label: {

                    HStack(spacing: 14) {

                        Image(
                            systemName: "lock"
                        )
                        .font(.title3)
                        .frame(
                            width: 36,
                            height: 36
                        )
                        .background(
                            .blue.opacity(0.10)
                        )
                        .clipShape(
                            RoundedRectangle(
                                cornerRadius: 9
                            )
                        )

                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {

                            Text("Change Password")
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)

                            Text(
                                "Update your account password"
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(
                            systemName: "chevron.right"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(
                        .gray.opacity(0.10)
                    )
                    .cornerRadius(14)
                }
                .buttonStyle(.plain)
            }
            .padding()
        }


        .sheet(
            isPresented: $showProfileSheet
        ) {

            ProfileView(
                user: user
            )
        }


        .sheet(
            isPresented: $showChangePasswordSheet
        ) {

            ChangePasswordView(
                user: user,
                viewModel: viewModel
            )
        }
    }
}
