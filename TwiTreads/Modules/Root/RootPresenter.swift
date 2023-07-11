//
//  RootPresenter.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

protocol RootPresenter: AnyObservableObject {
    
    var rootScreen: RootScreen { get set }
    
    var tabBarPresenter: any TabBarPresenter { get }
}

enum RootScreen {
    case tabBar
}

class RootPresenterImpl: RootPresenter, ObservableObject {
    
    struct Dependencies {
        let getTabBarPresenter: () -> any TabBarPresenter
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: RootPresenter
    
    @Published var rootScreen: RootScreen = .tabBar
    
    var tabBarPresenter: TabBarPresenter {
        dependencies.getTabBarPresenter()
    }
    
    // MARK: private
    
    private let dependencies: Dependencies
}

