//
//  PDFResourceView.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 11/9/2026.
//

import SwiftUI
import PDFKit

struct PDFResourceView: UIViewRepresentable {

    let fileURL: URL

    // creates and configures the PDF view using the selected resource file
    func makeUIView(
        context: Context
    ) -> PDFView {

        let pdfView = PDFView()

        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical

        if let document =
            PDFDocument(
                url: fileURL
            ) {

            pdfView.document =
                document
        }

        return pdfView
    }

    // updates the PDF document when the resource file changes
    func updateUIView(
        _ uiView: PDFView,
        context: Context
    ) {

        if uiView.document?.documentURL
            != fileURL {

            uiView.document =
                PDFDocument(
                    url: fileURL
                )
        }
    }
}
