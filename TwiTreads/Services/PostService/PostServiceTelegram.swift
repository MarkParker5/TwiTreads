//
//  PostServiceTelegram.swift
//  TwiTreads
//
//  Created by Mark Parker on 26/07/2023.
//

import Foundation
import Alamofire

class PostServiceTelegram: PostService {
    
    var isLoggedIn: Bool {
        credentials != nil
    }
    
    var user: User {
        get async throws {
            if let channel = credentials?.channel {
                return User(username: channel)
            } else {
                throw NSError(domain: "PostServiceTelegram", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not logged in"])
            }
        }
    }
    
    func handleAuthUrl(url: URL) async throws {}
    
    func login(credentials: Credentials?) async throws {
        guard let credentials else { return }
        self.credentials = ChannelCredentials(token: credentials.password, channel: credentials.username)
    }
    
    func post(message: String) async throws {
        guard let credentials else {
            throw NSError(domain: "PostServiceTelegram", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not logged in"])
        }
        try await post(botToken: credentials.token, channel: credentials.channel, message: message)
    }
    
    // MARK: private
    
    @UserDefaultCodable(key: "PostServiceTelegram.credentials", defaultValue: nil)
    private var credentials: ChannelCredentials?
    
    func post(botToken: String, channel: String, message: String) async throws {
        let baseURL = "https://api.telegram.org/bot\(botToken)/sendMessage"
        let parameters: [String: String] = [
            "chat_id": channel,
            "text": message
        ]
        
        let response = try await AF.request(baseURL, method: .get, parameters: parameters)
            .validate()
            .serializingData()
            .value
    }
}

fileprivate struct ChannelCredentials: Codable {
    let token: String
    let channel: String
}
