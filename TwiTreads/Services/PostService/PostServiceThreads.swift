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
    }
    
    // MARK: PostService
    
    var isLoggedIn: Bool {
        instagramApiToken != nil
    }
    
    func login(credentials: Credentials?) async throws {
        guard let credentials else { return }
        username = credentials.username
        
        let instPublicKey = try await getInstagramPublicKey()
        let timestampString = String(Int(Date().timeIntervalSince1970))
        let string = "\(timestampString)\n\(credentials.password)"
        let encryptedPassword = try dependencies.cryptoService.encryptRSA(string: string, publicKey: instPublicKey.publicKey)
        
        instagramApiToken = try await getInstagramApiToken(
            encryptedPassword: encryptedPassword,
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
    
    @discardableResult
    private func createThread(caption: String, url: String? = nil, imageUrl: String? = nil, replyTo: Int? = nil) async throws -> Thread {
        let parameters = ThreadParameters(caption: caption, url: url, imageUrl: imageUrl, replyTo: replyTo)
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let requestData = try encoder.encode(parameters)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let response = try await AF.request(
            "\(instagramApiUrl)/media/configure_text_only_post/",
            method: .post,
            parameters: requestData,
            headers: headers
        ).serializingDecodable(Thread.self, decoder: decoder).value
        return response
    }
    
    // MARK: helpers
    
    func getUserId() async throws -> Int {
        let url = "\(instagramApiUrl)/users/\(username!)/usernameinfo/"
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
        let blockVersion = "5f56efad68e1edec7801f630b5c122704ec5378adbee6609a448f105f34a9c73"

        let params = [
            "client_input_params": [
                "password": "#PWD_INSTAGRAM:4:\(timestamp):\(encryptedPassword)",
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
            let dataTask = request.serializingDecodable(LoginResponse.self)
            let value = try await dataTask.value
            return value.loggedInUser.pk
        } catch {
            print(Self.self, #function, #line, error, "\n")
            throw error
        }
    }
    
    private func createDeviceHash() -> String {
        let string = String(format: "%f", Date().timeIntervalSince1970)
        let hashString = dependencies.cryptoService.sha256(string: string, prefix: 16)
        return "android-\(hashString)"
    }
}

// MARK: - Models

fileprivate struct InstagramPublicKey: Codable {
    let keyId: String
    let publicKey: String
}

struct UserInfo: Codable {
    let id: Int
    let username: String
    let fullName: String
    let isPrivate: Bool
    let profilePicUrl: String
    let isVerified: Bool
}

fileprivate struct LoginResponse: Codable {
    let loggedInUser: LoggedInUser
    
    struct LoggedInUser: Codable {
        let pk: String
    }
}

fileprivate struct ThreadParameters: Codable {
    let caption: String
    let url: String?
    let imageUrl: String?
    let replyTo: Int?
}

struct Thread: Codable {
    let threadId: String
    let threadTitle: String
    let threadType: String
    let users: [UserInfo]
}
