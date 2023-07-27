//
//  PostServiceThreads.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation
import Alamofire

class PostServiceThreads: PostService {
    
    struct Dependencies {
        let cryptoService: CryptoService
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        Task {
            userId = try await getUserId()
        }
    }
    
    // MARK: PostService
    
    var isLoggedIn: Bool {
        instagramApiToken != nil
    }
    
    var user: User {
        get async throws {
            guard let username else {
                throw noUsernameError
            }
            let userInfo = try await getUserInfo(username: username)
            return User(username: userInfo.user.username)
        }
    }
    
    func login(credentials: Credentials?) async throws {
        guard let credentials else { return }
        username = credentials.username
        
        let instPublicKey = try await getInstagramPublicKey()
        let timestampString = String(Int(Date().timeIntervalSince1970))
        
        instagramApiToken = try await getInstagramApiToken(
            encryptedPassword: credentials.password,
            instagramPublicKeyId: instPublicKey.keyId,
            timestamp: timestampString
        )
        
        userId = try await getUserId()
    }
    
    func handleAuthUrl(url: URL) async throws {}
    
    func post(message: String) async throws {
        try await createThread(caption: message)
    }
    
    // MARK: private
    
    private let dependencies: Dependencies
    private let instagramApiUrl = "https://i.instagram.com/api/v1"
    private lazy var deviceId: String = createDeviceHash()
    
    @UserDefault(key: "PostServiceThreads.username", defaultValue: nil)
    private var username: String?
    
    @UserDefault(key: "PostServiceThreads.userId", defaultValue: nil)
    private var userId: Int?
    
    @UserDefault(key: "PostServiceThreads.instagramApiToken", defaultValue: nil)
    private var instagramApiToken: String?
    
    private var noUsernameError: NSError {
        NSError(domain: "PostServiceThreads", code: 0, userInfo: [NSLocalizedDescriptionKey: "User is not logged in"])
    }
    
    private var headers: HTTPHeaders {
        [
            "User-Agent": "Barcelona 289.0.0.77.109 Android",
            "Sec-Fetch-Site": "same-origin",
            "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
            "Authorization": "Bearer IGT:2:\(instagramApiToken!)"
        ]
    }
    
    private var publicHeaders: HTTPHeaders {
        [
            "User-Agent": "Barcelona 289.0.0.77.109 Android",
            "Sec-Fetch-Site": "same-origin",
            "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
        ]
    }
    
    private func getUserInfo(username: String) async throws -> UserInfo {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try await AF.request(
            "\(instagramApiUrl)/users/\(username)/usernameinfo/",
            headers: headers
        ).serializingDecodable(UserInfo.self, decoder: decoder).value
        return response
    }
    
//    @discardableResult
    private func createThread(caption: String, url: String? = nil, imageUrl: String? = nil, replyTo: Int? = nil) async throws { //} -> Thread {
        guard let userId else { return }
        let parameters = [
            "text_post_app_info": "{\"reply_control\":0}",
            "publish_mode": "text_post",
            "timezone_offset": "0",
            "source_type": "4",
            "caption": caption,
            "_uid": String(userId),
            "device_id": deviceId,
            "upload_id": String(Int(Date().timeIntervalSince1970)),
        ] as [String: String]
        
        let parametersString = "SIGNATURE." + String(data: try JSONEncoder().encode(parameters), encoding: .utf8)!
        
        _ = try await AF.request(
            "\(instagramApiUrl)/media/configure_text_only_post/",
            method: .post,
            parameters: ["signed_body": parametersString],
            headers: headers
        ).serializingData().value//.serializingDecodable(Thread.self, decoder: decoder).value
    }
    
    // MARK: helpers
    
    private func getUserId() async throws -> Int {
        guard let username else { throw noUsernameError }
        
        let url = "\(instagramApiUrl)/users/\(username)/usernameinfo/"
        let request = AF.request(url, headers: headers)
        let response = try await request.serializingString().value
        
        guard
            let data = response.data(using: .utf8),
            let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any],
            let userIdAsString = (json["user"] as? [String: Any])?["pk"] as? String,
            let userId = Int(userIdAsString)
        else {
            return 0
        }
        
        return userId
    }
    
    private func getInstagramPublicKey() async throws -> InstagramPublicKey {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let request = AF.request("\(instagramApiUrl)/qe/sync/", method: .post, parameters: [:], headers: publicHeaders)
        let dataTask = request.serializingString()
        let response = await dataTask.response
        let keyId = response.response?.headers.value(for: "ig-set-password-encryption-key-id")
        let publicKey = response.response?.headers.value(for: "ig-set-password-encryption-pub-key")
        guard let keyId, let publicKey else {
            throw NSError(domain: "PostServiceThreads", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get Instagram public key"])
        }
        return InstagramPublicKey(keyId: keyId, publicKey: publicKey)
    }
    
    private func getInstagramApiToken(encryptedPassword: String, instagramPublicKeyId: String, timestamp: String) async throws -> String {
        guard let username else { throw noUsernameError }
        
        let blockVersion = "5f56efad68e1edec7801f630b5c122704ec5378adbee6609a448f105f34a9c73"

        let params = [
            "client_input_params": [
                "password": "#PWD_INSTAGRAM:0:\(timestamp):\(encryptedPassword)", // 4
                "contact_point": username,
                "device_id": deviceId
            ],
            "server_params": [
                "credential_type": "password",
                "device_id": deviceId
            ]
        ]

        let clientContext = [
            "bloks_version": blockVersion,
            "styles_id": "instagram"
        ]
        
        guard
            let paramsData = try? JSONSerialization.data(withJSONObject: params, options: []),
            let paramsString = String(data: paramsData, encoding: .utf8),
            let clientContextData = try? JSONSerialization.data(withJSONObject: clientContext, options: []),
            let clientContextString = String(data: clientContextData, encoding: .utf8)
        else {
            throw NSError(domain: "PostServiceThreads", code: 0, userInfo: [NSLocalizedDescriptionKey: "Can't serialize params or client context"])
        }
        
        let parameters = [
            "params": paramsString,
            "bk_client_context": clientContextString,
            "bloks_versioning_id": blockVersion
        ]

        do {
            let request = AF.request("\(instagramApiUrl)/bloks/apps/com.bloks.www.bloks.caa.login.async.send_login_request/", method: .post, parameters: parameters, headers: publicHeaders)
            let string = try await request.serializingString().value
            let regex = try NSRegularExpression(pattern: #"Bearer\ IGT\:2\:(?<token>.*?\=)\\"#, options: [])
            let range = NSRange(location: 0, length: string.count)
            let match = regex.firstMatch(in: string, options: [], range: range)
            guard
                let tokenRange = match?.range(withName: "token")
            else {
                throw NSError(domain: "PostServiceThreads", code: 0, userInfo: [NSLocalizedDescriptionKey: "Can't find token"])
            }
            return (string as NSString).substring(with: tokenRange)
        } catch {
            print(Self.self, #function, #line, error, "\n")
            throw error
        }
    }
    
    private func createDeviceHash() -> String {
        let string = String(format: "%f", Date().timeIntervalSince1970)
        let hashString = dependencies.cryptoService.sha256(string: string, prefix: 8)
        return "ios-\(hashString)"
    }
}

// MARK: - Models

fileprivate struct InstagramPublicKey: Codable {
    let keyId: String
    let publicKey: String
}

fileprivate struct UserInfo: Codable {
    let user: User
    
    struct User: Codable {
        let username: String
        let fullName: String
        let biography: String
        let profilePicUrl: URL
    }
}
