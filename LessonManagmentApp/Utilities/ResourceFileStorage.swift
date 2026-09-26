//
//  ResourceFileStorage.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation

enum ResourceFileStorage {

    // saves a resource file into its own folder in the app's Documents directory
    static func saveFile(
        from sourceURL: URL,
        resourceID: UUID
    ) throws -> String {

        let fileManager = FileManager.default

        let documentsURL =
            fileManager.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first!

        let resourcesFolder =
            documentsURL
                .appendingPathComponent(
                    "Resources",
                    isDirectory: true
                )

        // creates the main Resources folder if it does not already exist
        if !fileManager.fileExists(
            atPath: resourcesFolder.path
        ) {

            try fileManager.createDirectory(
                at: resourcesFolder,
                withIntermediateDirectories: true
            )
        }

        let resourceFolder =
            resourcesFolder
                .appendingPathComponent(
                    resourceID.uuidString,
                    isDirectory: true
                )

        // creates a unique folder for the resource using its ID
        if !fileManager.fileExists(
            atPath: resourceFolder.path
        ) {

            try fileManager.createDirectory(
                at: resourceFolder,
                withIntermediateDirectories: true
            )
        }

        let destinationURL =
            resourceFolder
                .appendingPathComponent(
                    sourceURL.lastPathComponent
                )
        
        // removes an existing file with the same name before copying the new file
        if fileManager.fileExists(
            atPath: destinationURL.path
        ) {

            try fileManager.removeItem(
                at: destinationURL
            )
        }

        try fileManager.copyItem(
            at: sourceURL,
            to: destinationURL
        )

        return sourceURL.lastPathComponent
    }


    // builds the local file URL for a stored resource
    static func fileURL(
        resourceID: UUID,
        fileName: String
    ) -> URL {

        let documentsURL =
            FileManager.default.urls(
                for: .documentDirectory,
                in: .userDomainMask
            ).first!

        return documentsURL
            .appendingPathComponent(
                "Resources"
            )
            .appendingPathComponent(
                resourceID.uuidString
            )
            .appendingPathComponent(
                fileName
            )
    }
    
    // removes the old file and saves its replacement
    static func replaceFile(
        from sourceURL: URL,
        resourceID: UUID,
        oldFileName: String
    ) throws -> String {

        let fileManager = FileManager.default

        let oldFileURL =
            fileURL(
                resourceID: resourceID,
                fileName: oldFileName
            )

        if fileManager.fileExists(
            atPath: oldFileURL.path
        ) {
            try fileManager.removeItem(
                at: oldFileURL
            )
        }

        return try saveFile(
            from: sourceURL,
            resourceID: resourceID
        )
    }
    
    // deletes a resource file from local storage if it exists
    static func deleteFile(
        resourceID: UUID,
        fileName: String
    ) throws {

        let fileURL =
            fileURL(
                resourceID: resourceID,
                fileName: fileName
            )

        if FileManager.default.fileExists(
            atPath: fileURL.path
        ) {

            try FileManager.default.removeItem(
                at: fileURL
            )
        }
    }
}
