//
//  PostPresenter.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

protocol PostPresenter: AnyObservableObject {
 
    var text: String { get set }
    
    var isTwitterOn: Bool { get set }
    
    var isThreadsOn: Bool { get set }
    
    var isTelegramOn: Bool { get set }
    
    func onPostTap()
}

class PostPresenterImpl: PostPresenter, ObservableObject {
    
    struct Dependencies {
        let postServiceProvider: PostServiceProvider
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    @Published var text: String = ""
    @Published var isThreadsOn: Bool = true
    @Published var isTwitterOn: Bool = true
    @Published var isTelegramOn: Bool = true
    
    func onPostTap() {
        if isThreadsOn {
            Task {
                try? await dependencies.postServiceProvider.twitterService.post(message: text)
            }
        }
        if isTwitterOn {
            Task {
                try? await dependencies.postServiceProvider.threadsService.post(message: text)
            }
        }
        if isTelegramOn {
            Task {
                try? await dependencies.postServiceProvider.telegramService.post(message: text)
            }
        }
    }
    
    // MARK: private
    
    private let dependencies: Dependencies
}
