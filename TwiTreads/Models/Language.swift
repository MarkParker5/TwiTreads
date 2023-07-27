//
//  Language.swift
//  TwiTreads
//
//  Created by Mark Parker on 27/07/2023.
//

import Foundation

struct Language: Identifiable, Hashable {
    let code: String
    let name: String
    
    var id: String { code }
}

extension Language {
    static let english = Language(code: "en", name: "English")
}
