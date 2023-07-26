//
//  PostServiceMock.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

class PostServiceMock: PostService {
    
    var isLoggedIn: Bool { true }
    
    var user: User { get async throws { User(username: "mock") } }
    
    func login(credentials: Credentials?) async throws {}
    
    func handleAuthUrl(url: URL) async throws {}
    
    func post(message: String) async throws {}
}
