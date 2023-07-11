//
//  DIContainer.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

protocol DIContainer {
    func register<Component>(type: Component.Type, component: Any)
    func resolve<Component>(type: Component.Type) -> Component
}

final class DIContainerImpl: DIContainer {
    
    private var components: [String: Any] = [:]
    
    func register<Component>(type: Component.Type, component: Any) {
        components["\(type)"] = component
    }
    
    func resolve<Component>(type: Component.Type) -> Component {
        guard let component = components["\(type)"] as? Component else {
            fatalError("Missing component \(type) in DIContainer")
        }
        return component
    }
}
