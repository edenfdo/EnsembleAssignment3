//
//  ResourcePreviewView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 13/9/2026.
//

import SwiftUI
import UIKit

struct ResourcePreviewView: View {

    let resource: Resource
    let subtitle: String
    let onClose: () -> Void

    var body: some View {

        VStack(
            alignment: .leading,
            spacing: 14
        ) {

            HStack {

                VStack(
                    alignment: .leading,
                    spacing: 3
                ) {

                    Text(resource.title)
                        .font(.headline)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Button {
                    onClose()
                } label: {

                    Image(
                        systemName: "xmark"
                    )
                    .font(.headline)
                }
            }

            Divider()

            if resource.fileType == .pdf {

                PDFResourceView(
                    fileURL: resource.localFileURL
                )
                .frame(height: 430)
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: 10
                    )
                )

            } else {

                imageViewer(
                    resource
                )
            }

            Divider()

            HStack {

                Image(
                    systemName:
                        resource.fileType == .pdf
                        ? "doc.fill"
                        : "photo.fill"
                )

                Text(resource.fileName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()
            }
        }
        .padding()
        .frame(
            maxWidth: 360
        )
        .background(
            Color(.systemBackground)
        )
        .cornerRadius(18)
        .shadow(radius: 12)
        .padding()
    }

    // loads and displays an image resource from local storage
    @ViewBuilder
    private func imageViewer(
        _ resource: Resource
    ) -> some View {

        if let uiImage =
            UIImage(
                contentsOfFile:
                    resource.localFileURL.path
            ) {

            Image(
                uiImage: uiImage
            )
            .resizable()
            .scaledToFit()
            .frame(
                maxWidth: .infinity,
                maxHeight: 430
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 10
                )
            )

        } else {

            VStack(
                spacing: 10
            ) {

                Image(
                    systemName: "photo"
                )
                .font(
                    .system(size: 50)
                )
                .foregroundStyle(.secondary)

                Text(
                    "Unable to load image."
                )
                .foregroundStyle(.secondary)
            }
            .frame(
                maxWidth: .infinity,
                minHeight: 220
            )
        }
    }
}
