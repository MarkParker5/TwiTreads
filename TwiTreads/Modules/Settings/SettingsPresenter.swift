//
//  SettingsPresenter.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

protocol SettingsPresenter: AnyObservableObject {
    
    func onAddTwitterTap()
    
    func onAddThreadsTap()
}

class SettingsPresenterImpl: SettingsPresenter, ObservableObject {
    
    struct Dependencies {
        let postServiceProvider: PostServiceProvider
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: SettingsPresenter
    
    func onAddTwitterTap() {
        Task {
            try? await dependencies.postServiceProvider.twitterService.login()
        }
    }
    
    func onAddThreadsTap() {
        
    }
    
    // MARK: private
    
    private let dependencies: Dependencies
}
