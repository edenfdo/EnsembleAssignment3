//
//  SupabaseService.swift
//  LessonManagmentApp
//
//  Created by Eden Fernando on 1/10/2026.
//

import Foundation
import Supabase

enum SupabaseService {

    static let client = SupabaseClient(
        supabaseURL: URL(string: "https://kefakpygltmjgoetepzh.supabase.co")!,
        supabaseKey: "sb_publishable_PBbRkEUVxNnchwe_fy01TA_VJ0YqW8H",
        options: SupabaseClientOptions(
            auth: .init(
                emitLocalSessionAsInitialSession: true
            )
        )
    )
   
}
