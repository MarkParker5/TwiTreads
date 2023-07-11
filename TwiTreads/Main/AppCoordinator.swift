//
//  TwiTreadsAppCoordinator.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

protocol AppCoordinator {
    var presentersFactory: PresentersFactory { get }
}

final class AppCoordinatorImpl: AppCoordinator {
    
    init() {
        diContainer.register(
            type: PostServiceProvider.self,
            component: PostServiceProviderImpl(
                dependencies: .init(
                    twitterService: PostServiceTwitter(),
                    threadsService: PostServiceThreads()
                )
            )
        )
    }
    
    lazy var presentersFactory: PresentersFactory = PresentersFactoryImpl(diContainer: diContainer)
    
    // MARK: private
    
    let diContainer = DIContainerImpl()
}
