//
//  UserDefault.swift
//  TwiTreads
//
//  Created by Mark Parker on 12/07/2023.
//

import Foundation

enum DefaultsKeys: String {
    case twitterToken
    // case threadsToken
}

@propertyWrapper
struct UserDefault<Value> {
    
    let key: DefaultsKeys
    let defaultValue: Value
    let container: UserDefaults = .standard

    lazy var wrappedValue: Value = container.object(forKey: key.rawValue) as? Value ?? defaultValue {
        didSet {
            container.set(wrappedValue, forKey: key.rawValue)
        }
    }
}

@propertyWrapper
struct UserDefaultCodable<Value: Codable> {
    
    let key: DefaultsKeys
    let defaultValue: Value
    let container: UserDefaults = .standard

    lazy var wrappedValue: Value = decode() ?? defaultValue {
        didSet {
            guard
                let data = try? JSONEncoder().encode(wrappedValue)
            else {
                return
            }
            container.set(data, forKey: key.rawValue)
        }
    }
    
    private func decode() -> Value? {
        guard
            let data = container.object(forKey: key.rawValue) as? Data,
            let value = try? JSONDecoder().decode(Value.self, from: data)
        else {
            return nil
        }
        return value
    }
}
