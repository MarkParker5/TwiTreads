//
//  SettingsPresenter.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

protocol SettingsPresenter: AnyObservableObject {
    
    var credentials: Credentials { get set }
    
    var isLoginPresented: Bool { get set }
    
    var isTwitterLoggedIn: Bool { get }
    
    var isThreadsLoggedIn: Bool { get }
    
    func onAppear()
    
    func onAddTwitterTap()
    
    func onAddThreadsTap()
    
    func onLoginTap()
}

class SettingsPresenterImpl: SettingsPresenter, ObservableObject {
    
    struct Dependencies {
        let postServiceProvider: PostServiceProvider
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: SettingsPresenter
    
    @Published var credentials = Credentials(username: "", password: "")
    
    @Published var isLoginPresented: Bool = false
    
    @Published var isTwitterLoggedIn: Bool = false
    
    @Published var isThreadsLoggedIn: Bool = false
    
    func onAppear() {
        isTwitterLoggedIn = dependencies.postServiceProvider.twitterService.isLoggedIn
        isThreadsLoggedIn = dependencies.postServiceProvider.threadsService.isLoggedIn
    }
    
    func onAddTwitterTap() {
        Task {
            do {
                // uses oauth via twitter app/website with redirect urls so credentials are not needed
                try await dependencies.postServiceProvider.twitterService.login()
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
            } catch {
                print(Self.self, #function, #line, error, "\n")
            }
            isLoginPresented = false
            credentials = Credentials(username: "", password: "")
        }
    }
    
    // MARK: private
    
    private let dependencies: Dependencies
}
