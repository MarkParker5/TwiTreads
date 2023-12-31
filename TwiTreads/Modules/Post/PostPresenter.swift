//
//  PostPresenter.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation
import Combine

protocol PostPresenter: AnyObservableObject {
 
    var text: String { get set }
    
    var translatedText: String { get set }
    
    var selectedLanguage: Language { get }
    
    var languages: [Language] { get set }
    
    var isTranslateOn: Bool { get set }
    
    var isTwitterOn: Bool { get set }
    
    var isThreadsOn: Bool { get set }
    
    var isTelegramOn: Bool { get set }
    
    func onLanguageTap(_ language: Language)
    
    func onPostTap()
}

class PostPresenterImpl: PostPresenter, ObservableObject {
    
    struct Dependencies {
        let postServiceProvider: PostServiceProvider
        let translateService: TranslateService
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        
        // sinks

        $text.receive(on: DispatchQueue.main).sink { [unowned self] text in
            defaults.text = text
            translate()
        }.store(in: &bag)
        
        $selectedLanguageCode.receive(on: DispatchQueue.main).sink { [unowned self] code in
            defaults.selectedLanguageCode = code
            translate()
        }.store(in: &bag)
        
        $isTranslateOn.receive(on: DispatchQueue.main).sink { [unowned self] isOn in
            defaults.isTranslateOn = isOn
            translate()
        }.store(in: &bag)
        
        $isTwitterOn.receive(on: DispatchQueue.main).sink { [unowned self] isOn in
            defaults.isTwitterOn = isOn
        }.store(in: &bag)
        
        $isThreadsOn.receive(on: DispatchQueue.main).sink { [unowned self] isOn in
            defaults.isThreadsOn = isOn
        }.store(in: &bag)
        
        $isTelegramOn.receive(on: DispatchQueue.main).sink { [unowned self] isOn in
            defaults.isTelegramOn = isOn
        }.store(in: &bag)
        
        // defaults
        
        text = defaults.text ?? ""
        selectedLanguageCode = defaults.selectedLanguageCode ?? selectedLanguageCode
        isTranslateOn = defaults.isTranslateOn
        isTwitterOn = defaults.isTwitterOn
        isThreadsOn = defaults.isThreadsOn
        isTelegramOn = defaults.isTelegramOn
        
        // tasks
        
        Task {
            do {
                await updateLanguages(try await dependencies.translateService.languages)
            } catch {
                print(Self.self, #function, #line, error, "\n")
            }
            translate()
        }
    }
    
    @Published var text: String = ""
    @Published var translatedText: String = ""
    @Published var languages: [Language] = []
    @Published var selectedLanguageCode: String = Language.english.code
    @Published var isTranslateOn: Bool = false
    @Published var isThreadsOn: Bool = true
    @Published var isTwitterOn: Bool = true
    @Published var isTelegramOn: Bool = true

    var selectedLanguage: Language {
        languages.first { $0.code == selectedLanguageCode } ?? .english
    }
    
    func onPostTap() {
        let text = isTranslateOn ? translatedText : text
        
        if isTwitterOn {
            Task {
                do {
                    try await dependencies.postServiceProvider.twitterService.post(message: text)
                } catch {
                    print(Self.self, #function, #line, error, "\n")
                }
            }
        }
        if isThreadsOn {
            Task {
                do {
                    try await dependencies.postServiceProvider.threadsService.post(message: text)
                } catch {
                    print(Self.self, #function, #line, error, "\n")
                }
            }
        }
        if isTelegramOn {
            Task {
                do {
                    try await dependencies.postServiceProvider.telegramService.post(message: text)
                } catch {
                    print(Self.self, #function, #line, error, "\n")
                }
            }
        }
    }
    
    func onLanguageTap(_ language: Language) {
        selectedLanguageCode = language.code
        translate()
    }
    
    // MARK: private
    
    private let dependencies: Dependencies
    private var bag = Set<AnyCancellable>()
    
    private func translate() {
        guard isTranslateOn else { return }
        Task {
            do {
                let translated = try await dependencies.translateService.translate(
                    text: text,
                    to: selectedLanguage
                )
                await updateTranslation(string: translated ?? "")
            } catch {
                print(Self.self, #function, #line, error, "\n")
            }
        }
    }
    
    @MainActor
    private func updateTranslation(string: String) {
        translatedText = string
    }
    
    @MainActor
    private func updateLanguages(_ languages: [Language]) {
        self.languages = languages
    }
    
    // MARK: Defaults
    
    private var defaults = Defaults()
    
    private struct Defaults {
        
        @UserDefault(key: "PostPresenter.Defaults.text", defaultValue: nil)
        var text: String?
        
        @UserDefault(key: "PostPresenter.Defaults.selectedLanguageCode", defaultValue: nil)
        var selectedLanguageCode: String?
        
        @UserDefault(key: "PostPresenter.Defaults.isTranslateOn", defaultValue: false)
        var isTranslateOn: Bool
        
        @UserDefault(key: "PostPresenter.Defaults.isTwitterOn", defaultValue: true)
        var isTwitterOn: Bool

        @UserDefault(key: "PostPresenter.Defaults.isThreadsOn", defaultValue: true)
        var isThreadsOn: Bool

        @UserDefault(key: "PostPresenter.Defaults.isTelegramOn", defaultValue: true)
        var isTelegramOn: Bool
    }
}
