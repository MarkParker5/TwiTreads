//
//  UserDefault.swift
//  TwiTreads
//
//  Created by Mark Parker on 12/07/2023.
//

import Foundation

enum DefaultsKeys: String {
    case key
}

@propertyWrapper
struct UserDefault<Value> {
    
    let key: String
    let defaultValue: Value
    let container: UserDefaults = .standard
    
    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    init(key: DefaultsKeys, defaultValue: Value) {
        self.key = key.rawValue
        self.defaultValue = defaultValue
    }

    lazy var wrappedValue: Value = container.object(forKey: key) as? Value ?? defaultValue {
        didSet {
            container.set(wrappedValue, forKey: key)
        }
    }
}

@propertyWrapper
struct UserDefaultCodable<Value: Codable> {
    
    let key: String
    let defaultValue: Value
    let container: UserDefaults = .standard
    
    init(key: String, defaultValue: Value) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    init(key: DefaultsKeys, defaultValue: Value) {
        self.key = key.rawValue
        self.defaultValue = defaultValue
    }

    lazy var wrappedValue: Value = decode() ?? defaultValue {
        didSet {
            guard
                let data = try? JSONEncoder().encode(wrappedValue)
            else {
                return
            }
            container.set(data, forKey: key)
        }
    }
    
    private func decode() -> Value? {
        guard
            let data = container.object(forKey: key) as? Data,
            let value = try? JSONDecoder().decode(Value.self, from: data)
        else {
            return nil
        }
        return value
    }
}
