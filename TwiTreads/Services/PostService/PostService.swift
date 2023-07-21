//
//  PostService.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

protocol PostService {
    
    var isLoggedIn: Bool { get }
    
    func login(credentials: Credentials?) async throws
    
    func handleAuthUrl(url: URL) async throws
    
    // var userInfo: UserInfo async throws
    
    func post(message: String) async throws
}

extension PostService {
    func login() async throws {
        try await login(credentials: nil)
    }
}
