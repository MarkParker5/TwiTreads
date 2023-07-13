//
//  ViewModelsFactory.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

protocol PresentersFactory {
    var rootPresenter: any RootPresenter { get }
}

final class PresentersFactoryImpl: PresentersFactory {
    
    var rootPresenter: RootPresenter {
        RootPresenterImpl(dependencies: .init(
            getTabBarPresenter: tabBarPresenter
        ))
    }
    
    func tabBarPresenter() -> TabBarPresenter {
        TabBarPresenterImpl(dependencies: .init(
            getFeedPresenter: feedPresenter,
            getPostPresenter: postPresenter,
            getSettingsPresenter: settingsPresenter
        ))
    }
    
    func feedPresenter() -> FeedPresenter {
        FeedPresenterImpl()
    }
    
    func postPresenter() -> PostPresenter {
        PostPresenterImpl(dependencies: .init(
            postServiceProvider: diContainer.resolve(type: PostServiceProvider.self)
        ))
    }
    
    func settingsPresenter() -> SettingsPresenter {
        SettingsPresenterImpl(dependencies: .init(
            postServiceProvider: diContainer.resolve(type: PostServiceProvider.self)
        ))
    }
    
    init(diContainer: DIContainer) {
        self.diContainer = diContainer
    }
    
    // MARK: private
    
    private let diContainer: DIContainer
}
