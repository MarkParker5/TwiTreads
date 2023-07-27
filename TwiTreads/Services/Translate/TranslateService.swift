//
//  TranslateService.swift
//  TwiTreads
//
//  Created by Mark Parker on 27/07/2023.
//

import Foundation
import Alamofire

protocol TranslateService {
    
    var languages: [Language] { get async throws }
    
    func translate(text: String, to: Language) async throws -> String?
}

class TranslateServiceImpl: TranslateService {
    
    var languages: [Language] {
        get async throws {
            Locale.availableIdentifiers
                .map {
                    Locale(identifier: $0)
                }
                .compactMap { locale in
                    guard
                        let languageCode = locale.language.languageCode?.identifier,
                        let languageName = locale.localizedString(forLanguageCode: languageCode)
                    else {
                        return nil
                    }
                    return Language(code: languageCode, name: languageName)
                }.reduce(into: [String: Language]()) { result, language in
                    result[language.code] = language // remove duplicates
                }.values
                .sorted {
                    $0.name < $1.name
                }
        }
    }
    
    func translate(text: String, to language: Language) async throws -> String? {
        let baseLink = "https://translate.google.com/m"
        let parameters: [String: String] = ["tl": language.code, "sl": "auto", "q": text]
        
        let string = try await AF.request(baseLink, method: .get, parameters: parameters, headers: ["User-Agent": "Mozilla/5.0"])
            .validate()
            .serializingString()
            .value
        
        let pattern = "(?s)class=\"(?:t0|result-container)\">(?<translated>.*?)<"
        let regex = try NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: string.count)
        let match = regex.firstMatch(in: string, options: [], range: range)
        guard
            let tokenRange = match?.range(withName: "translated")
        else {
            return nil
        }
        return (string as NSString).substring(with: tokenRange)
    }
}
