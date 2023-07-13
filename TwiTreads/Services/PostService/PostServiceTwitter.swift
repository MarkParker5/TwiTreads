//
//  PostServiceTwitter.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation
import UIKit
import TwitterAPIKit

class PostServiceTwitter: PostService {
    
    var isLoggedIn: Bool {
        accessToken != nil
    }
    
    func login() async throws {
        let authorizeURL = client.auth.oauth20.makeOAuth2AuthorizeURL(.init(
            clientID: Key.consumerKey,
            redirectURI: redirectUrl,
            state: "state",
            codeChallenge: codeChallenge,
            codeChallengeMethod: "plain",
            scopes: ["tweet.read", "tweet.write", "users.read", "offline.access"]
        ))!
        
        DispatchQueue.main.async {
            UIApplication.shared.open(authorizeURL)
        }
    }
    
    func handleAuthUrl(url: URL) async throws {
        guard
            let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
            let code = components.queryItems?.first(where: { $0.name == "code" })?.value
        else {
            return
        }
        
        let response = await client.auth.oauth20.postOAuth2AccessToken(.init(
            code: code,
            clientID: Key.consumerKey,
            redirectURI: redirectUrl,
            codeVerifier: codeChallenge
        )).responseObject
        
        switch response.result {
        case .success(let token):
            accessToken = token.accessToken
            refreshToken = token.refreshToken
        case .failure(let error):
            print("[Error]", Self.self, #function, #line, error)
        }
    }
    
    func post(message: String) async throws {
        try await refresh()
        let client = TwitterAPIClient(.bearer(accessToken!))
        let response = await client.v2.tweet.postTweet(PostTweetsRequestV2(text: message)).responseObject
        print(response)
    }
    
    func refresh() async throws {
        // TODO: refresh token
    }
    
    // MARK: private
    
    private let client = TwitterAPIClient(.basic(apiKey: Key.consumerKey, apiSecretKey: Key.consumerSecret))
    
    private let redirectUrl: String = "twitreads://auth-twitter"
    
    private let codeChallenge: String = "code challenge"

    @UserDefault(key: .twitterAccessToken, defaultValue: nil)
    private var accessToken: String?
    
    @UserDefault(key: .twitterRefreshToken, defaultValue: nil)
    private var refreshToken: String?
    
    private enum Key {
        static var consumerKey: String {
            try! InfoPlist.value(for: "TWITTER_CONSUMER_KEY")
        }
        
        static var consumerSecret: String {
            try! InfoPlist.value(for: "TWITTER_CONSUMER_SECRET")
        }
    }
}

// MARK: Schemas

fileprivate struct TweeterTokensResponse: Decodable {
    let accessToken: String
    let refreshToken: String 
}
