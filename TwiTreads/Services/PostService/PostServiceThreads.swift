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
        false
    }
    
    func login(credentials: Credentials?) async throws {
        guard let credentials else { return }
        username = credentials.username
        
        let instPublicKey = try await getInstagramPublicKey()
        let timestampString = String(Int(Date().timeIntervalSince1970))
        let encryptedPassword = dependencies.cryptoService.encryptRSA(string: "\(timestampString)\n\(credentials.password)", publicKey: instPublicKey.publicKey)!
        let base64Password = encryptedPassword.data(using: .utf8)!.base64EncodedString()
        
        let instagramApiToken = try await getInstagramApiToken(
            encryptedPassword: encryptedPassword,
            instagramPublicKeyId: instPublicKey.keyId,
            timestamp: timestampString
        )
        
        headers = [
            "Authorization": "Bearer IGT:2:\(instagramApiToken)",
            "User-Agent": "Barcelona 289.0.0.77.109 Android",
            "Sec-Fetch-Site": "same-origin",
            "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
        ]
        
        userId = try await getUserId()
    }
    
    func handleAuthUrl(url: URL) async throws {}
    
    func post(message: String) async throws {
        try await createThread(caption: message)
    }
    
    // MARK: private
    
    private let dependencies: Dependencies
    private let instagramApiUrl = "https://i.instagram.com/api/v1"
    private var username: String?
    private var headers: HTTPHeaders?
    private var userId: Int?
    private lazy var deviceId: String = createDeviceHash()
    
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
        let request = AF.request("\(instagramApiUrl)/qe/bootstrap/", headers: headers)
        let dataTask = request.serializingDecodable(InstagramPublicKey.self, decoder: decoder)
        let value = try await dataTask.value
        return value
    }
    
    private func getInstagramApiToken(encryptedPassword: String, instagramPublicKeyId: String, timestamp: String) async throws -> String {
        let parameters = LoginParameters(
            jazoest: "2725",
            phoneId: deviceId,
            _csrftoken: "missing",
            username: username!,
            adid: UUID().uuidString,
            guid: UUID().uuidString,
            deviceId: deviceId,
            password: "\(encryptedPassword)\n\(instagramPublicKeyId)\n\(timestamp)",
            loginAttemptCount: "0"
        )
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let requestData = try encoder.encode(parameters)
        let request = AF.request("\(instagramApiUrl)/accounts/login/", method: .post, parameters: requestData, headers: headers)
        let dataTask = request.serializingDecodable(LoginResponse.self)
        let value = try await dataTask.value
        return value.loggedInUser.pk
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

fileprivate struct LoginParameters: Codable {
    let jazoest: String
    let phoneId: String
    let _csrftoken: String
    let username: String
    let adid: String
    let guid: String
    let deviceId: String
    let password: String
    let loginAttemptCount: String
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
