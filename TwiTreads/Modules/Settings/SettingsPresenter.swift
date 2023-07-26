//
//  SettingsPresenter.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

@MainActor
protocol SettingsPresenter: AnyObservableObject {
    
    var isLoading: Bool { get }
    
    var credentials: Credentials { get set }
    
    var isLoginPresented: Bool { get set }
    
    var twitterUser: User? { get }
    
    var threadsUser: User? { get }
    
    func onAppear()
    
    func onAddTwitterTap()
    
    func onAddThreadsTap()
    
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
    @Published var isLoginPresented: Bool = false
    @Published var twitterUser: User?
    @Published var threadsUser: User?
    
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
        isLoginPresented = true
    }
    
    func onLoginTap() {
        Task {
            do {
                // unofficial reverse-engineered api imitates the instagram app so credentials are required
                try await dependencies.postServiceProvider.threadsService.login(credentials: credentials)
                await setThreadsUser(try? await dependencies.postServiceProvider.threadsService.user)
            } catch {
                print(Self.self, #function, #line, error, "\n")
            }
            isLoginPresented = false
            credentials = Credentials(username: "", password: "")
        }
    }
    
    // MARK: private
    
    private let dependencies: Dependencies
    
    private func setTwitterUser(_ user: User?) async {
        twitterUser = user
    }
    
    private func setThreadsUser(_ user: User?) async {
        threadsUser = user
    }
}
