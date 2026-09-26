//
//  MenuBarView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import SwiftUI

struct MenuBarView: View {

    @Binding var showMenu: Bool
    let onLogoTap: () -> Void

    var body: some View {

        HStack {

            Button {

                onLogoTap()

            } label: {

                Image("applogo")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: 120,
                        height: 50,
                        alignment: .leading
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            Button {

                showMenu = true

            } label: {

                Image(
                    systemName: "line.3.horizontal"
                )
                .font(.title)
            }
        }
    }
}
