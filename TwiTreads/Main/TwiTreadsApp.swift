//
//  TwiTreadsApp.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import SwiftUI

@main
struct TwiTreadsApp: App {
    
    private let coordinator: AppCoordinator = AppCoordinatorImpl()
    
    var body: some Scene {
        WindowGroup {
            RootView(presenter: coordinator.presentersFactory.rootPresenter)
        }
    }
}
