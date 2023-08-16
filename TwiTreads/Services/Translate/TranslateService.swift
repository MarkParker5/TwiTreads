//
//  TranslateService.swift
//  TwiTreads
//
//  Created by Mark Parker on 27/07/2023.
//

import Foundation
import SwiftyTranslate

protocol TranslateService {
    
    var languages: [Language] { get }
    
    func translate(text: String, to: Language) async throws -> String?
}

extension SwiftyTranslate: TranslateService {}
