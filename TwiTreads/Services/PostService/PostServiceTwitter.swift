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
        token != nil
    }
    
    func login(credentials: Credentials?) async throws {
        let client = TwitterAPIClient(.basic(apiKey: Key.consumerKey, apiSecretKey: Key.consumerSecret))
        
        let authorizeURL = client.auth.oauth20.makeOAuth2AuthorizeURL(.init(
            clientID: Key.consumerKey,
            redirectURI: redirectUrl,
            state: "state",
            codeChallenge: codeChallenge,
            codeChallengeMethod: "plain",
            scopes: scope
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
        
        let client = TwitterAPIClient(.basic(apiKey: Key.consumerKey, apiSecretKey: Key.consumerSecret))
        
        let response = await client.auth.oauth20.postOAuth2AccessToken(.init(
            code: code,
            clientID: Key.consumerKey,
            redirectURI: redirectUrl,
            codeVerifier: codeChallenge
        )).responseObject
        
        switch response.result {
        case .success(let token):
            self.token = .init(
                clientID: Key.consumerKey,
                scope: token.scope,
                tokenType: token.tokenType,
                expiresIn: token.expiresIn,
                accessToken: token.accessToken,
                refreshToken: token.refreshToken
            )
        case .failure(let error):
            print("[Error]", Self.self, #function, #line, error)
        }
    }
    
    func post(message: String) async throws {
        try await refresh()
        guard let token else { return }
        let client = TwitterAPIClient(.bearer(token.accessToken))
        let response = await client.v2.tweet.postTweet(PostTweetsRequestV2(text: message)).responseObject
        print(response)
    }
    
    func refresh() async throws {
        guard let token else { return }
        let client = TwitterAPIClient(.oauth20(token))
        let refresh = try await client.refreshOAuth20Token(
            type: .confidentialClient(
                clientID: Key.consumerKey,
                clientSecret: Key.consumerSecret
            )
        )
        guard refresh.refreshed else { return }
        self.token = refresh.token
    }
    
    // MARK: private
    
    private let redirectUrl: String = "twitreads://auth-twitter"
    private let codeChallenge: String = "code challenge"
    private let scope: [String] = ["tweet.read", "tweet.write", "users.read", "offline.access"]
    
    @UserDefaultCodable(key: "PostServiceTwitter.token", defaultValue: nil)
    private var token: TwitterAuthenticationMethod.OAuth20?
    
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
