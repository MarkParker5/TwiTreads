//
//  SettingsPresenter.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

enum SettingsSheet: String, Identifiable {
    case threadsLogin, telegramLogin
    
    var id: String {
        rawValue
    }
}

@MainActor
protocol SettingsPresenter: AnyObservableObject {
    
    var isLoading: Bool { get }
    
    var credentials: Credentials { get set }
    
    var presentedSheet: SettingsSheet? { get set }
    
    var twitterUser: User? { get }
    
    var threadsUser: User? { get }
    
    var telegramUser: User? { get }
    
    func onAppear()
    
    func onAddTwitterTap()
    
    func onAddThreadsTap()
    
    func onAddTelegramTap()
    
    func onLoginTap()
}

@MainActor
class SettingsPresenterImpl: SettingsPresenter, ObservableObject {
    
    struct Dependencies {
        let postServiceProvider: PostServiceProvider
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: SettingsPresenter
    
    @Published var isLoading: Bool = true
    @Published var credentials = Credentials(username: "", password: "")
    @Published var presentedSheet: SettingsSheet?
    @Published var twitterUser: User?
    @Published var threadsUser: User?
    @Published var telegramUser: User?
    
    func onAppear() {
        Task {
            isLoading = true
            
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    await self.setTwitterUser(try? await self.dependencies.postServiceProvider.twitterService.user)
                }
                group.addTask {
                    await self.setThreadsUser(try? await self.dependencies.postServiceProvider.threadsService.user)
                }
                group.addTask {
                    await self.setTelegramUser(try? await self.dependencies.postServiceProvider.telegramService.user)
                }
            }
            
            isLoading = false
        }
    }
    
    func onAddTwitterTap() {
        Task {
            do {
                // uses oauth via twitter app/website with redirect urls so credentials are not needed
                try await dependencies.postServiceProvider.twitterService.login()
                await setTwitterUser(try? await dependencies.postServiceProvider.twitterService.user)
            } catch {
                print(Self.self, #function, #line, error, "\n")
            }
        }
    }
    
    func onAddThreadsTap() {
        credentials = Credentials(username: "", password: "")
        presentedSheet = .threadsLogin
    }
    
    func onAddTelegramTap() {
        credentials = Credentials(username: "", password: "")
        presentedSheet = .telegramLogin
    }
    
    func onLoginTap() {
        Task {
            switch presentedSheet {
            case .threadsLogin:
                try await threadsLogin()
            case .telegramLogin:
                try await telegramLogin()
            case nil:
                break
            }
            
            presentedSheet = nil
            credentials = Credentials(username: "", password: "")
        }
    }
    
    // MARK: private
    
    private let dependencies: Dependencies
    
    private func threadsLogin() async throws {
        try await dependencies.postServiceProvider.threadsService.login(credentials: credentials)
        await setThreadsUser(try? await dependencies.postServiceProvider.threadsService.user)
    }
    
    private func telegramLogin() async throws {
        try await dependencies.postServiceProvider.telegramService.login(credentials: credentials)
        await setTelegramUser(try? await dependencies.postServiceProvider.telegramService.user)
    }
    
    private func setTwitterUser(_ user: User?) async {
        twitterUser = user
    }
    
    private func setThreadsUser(_ user: User?) async {
        threadsUser = user
    }
    
    private func setTelegramUser(_ user: User?) async {
        telegramUser = user
    }
}
