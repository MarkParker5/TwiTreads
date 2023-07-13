//
//  PostServiceMock.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

class PostServiceMock: PostService {
    
    var isLoggedIn: Bool { true }
    
    func login() async throws {
        
    }
    
    func handleAuthUrl(url: URL) async throws {
        
    }
    
    func post(message: String) async throws {
        
    }
}
