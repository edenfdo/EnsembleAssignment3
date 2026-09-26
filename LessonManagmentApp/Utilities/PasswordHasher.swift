//
//  PasswordHasher.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 12/9/2026.
//

import Foundation
import CryptoKit

enum PasswordHasher {

    // hashes a password using SHA-256 and converts the result into a hexadecimal String
    static func hash(
        _ password: String
    ) -> String {

        let data =
            Data(password.utf8)

        let digest =
            SHA256.hash(
                data: data
            )

        return digest.map {
            String(
                format: "%02x",
                $0
            )
        }
        .joined()
    }

    // checks whether a password matches a previously stored hash
    static func verify(
        password: String,
        hash: String
    ) -> Bool {

        hashPassword(password)
            == hash
    }

    // hashes the supplied password for comparison during verification
    private static func hashPassword(
        _ password: String
    ) -> String {

        hash(password)
    }
}
