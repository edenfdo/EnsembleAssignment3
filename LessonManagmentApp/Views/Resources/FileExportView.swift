//
//  FileExportView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 3/10/2026.
//

import SwiftUI
import UIKit

struct FileExportView:
    UIViewControllerRepresentable {

    let fileURL: URL

    func makeUIViewController(
        context: Context
    ) -> UIDocumentPickerViewController {

        UIDocumentPickerViewController(
            forExporting: [fileURL],
            asCopy: true
        )
    }

    func updateUIViewController(
        _ uiViewController:
            UIDocumentPickerViewController,
        context: Context
    ) {
    }
}
