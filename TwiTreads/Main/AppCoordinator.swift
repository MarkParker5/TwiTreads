//
//  TwiTreadsAppCoordinator.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation
import AlamofireNetworkActivityLogger
import SwiftyTranslate

protocol AppCoordinator {
    
    var presentersFactory: PresentersFactory { get }
    
    func onOpenUrl(url: URL)
}

final class AppCoordinatorImpl: AppCoordinator {
    
    init() {
        diContainer.register(type: CryptoService.self, component: CryptoServiceImpl())
        
        diContainer.register(type: TranslateService.self, component: SwiftyTranslate())
        
        diContainer.register(
            type: PostServiceProvider.self,
            component: PostServiceProviderImpl(
                dependencies: .init(
                    twitterService: PostServiceTwitter(),
                    threadsService: PostServiceThreads(dependencies: .init(
                        cryptoService: diContainer.resolve(type: CryptoService.self)
                    )),
                    telegramService: PostServiceTelegram()
                )
            )
        )
        
        NetworkActivityLogger.shared.level = .debug
        NetworkActivityLogger.shared.startLogging()
        NetworkActivityLogger.shared.stopLogging()
    }
    
    // MARK: AppCoordinator
    
    @MainActor lazy var presentersFactory: PresentersFactory = PresentersFactoryImpl(diContainer: diContainer)
    
    func onOpenUrl(url: URL) {
//        print("OnOpenUrl", url)
        
        Task {
            let postServiceProvider = diContainer.resolve(type: PostServiceProvider.self)
            let postService: PostService
            if URLComponents(url: url, resolvingAgainstBaseURL: true)?.host == "auth-twitter" {
                postService = postServiceProvider.twitterService
            } else {
                postService = postServiceProvider.threadsService
            }
            try? await postService.handleAuthUrl(url: url)
        }
    }
    
    // MARK: private
    
    let diContainer = DIContainerImpl()
}
