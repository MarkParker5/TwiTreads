//
//  TabBarPresenter.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

protocol TabBarPresenter: AnyObservableObject {
    var selectedTab: TabBarScreen { get set }
    
    var feedPresenter: any FeedPresenter { get }
    
    var postPresenter: any PostPresenter { get }
    
    var settingsPresenter: any SettingsPresenter { get }

}

enum TabBarScreen: Hashable {
    case feed
    case post
    case settings
}

class TabBarPresenterImpl: TabBarPresenter, ObservableObject {
    
    struct Dependencies {
        
        var getFeedPresenter: () -> any FeedPresenter
        
        var getPostPresenter: () -> any PostPresenter
        
        var getSettingsPresenter: () -> any SettingsPresenter
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: TabBarPresenter
    
    @Published var selectedTab: TabBarScreen = .post
    
    var feedPresenter: FeedPresenter {
        dependencies.getFeedPresenter()
    }
    
    var postPresenter: PostPresenter {
        dependencies.getPostPresenter()
    }
    
    var settingsPresenter: SettingsPresenter {
        dependencies.getSettingsPresenter()
    }
    
    // MARK: private
    
    private let dependencies: Dependencies
}

