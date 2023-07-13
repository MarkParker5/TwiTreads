//
//  UserDefault.swift
//  TwiTreads
//
//  Created by Mark Parker on 12/07/2023.
//

import Foundation

@propertyWrapper
struct UserDefault<Value> {
    
    enum DefaultsKeys: String {
        case twitterAccessToken
        case twitterRefreshToken
        // case threadsToken
    }
    
    let key: DefaultsKeys
    let defaultValue: Value
    let container: UserDefaults = .standard

    lazy var wrappedValue: Value = container.object(forKey: key.rawValue) as? Value ?? defaultValue {
        didSet {
            container.set(wrappedValue, forKey: key.rawValue)
        }
    }
}
