//
//  PostServiceProvider.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

protocol PostServiceProvider {
    
    // var allServices: [PostService] { get }
    
    var twitterService: PostService { get }
    
    var threadsService: PostService { get }
}

class PostServiceProviderImpl: PostServiceProvider {
    
    struct Dependencies {
        var twitterService: PostService
        var threadsService: PostService
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: PostServiceProvider
    
    var twitterService: PostService {
        dependencies.twitterService
    }
    
    var threadsService: PostService {
        dependencies.threadsService
    }
    
    // MARK: private
    
    private let dependencies: Dependencies
}
