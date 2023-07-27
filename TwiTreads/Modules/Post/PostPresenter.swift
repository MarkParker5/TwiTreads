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
    }
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        
        // sinks

        $text.receive(on: DispatchQueue.main).sink { [unowned self] text in
            defaults.text = text
            translate()
        }.store(in: &bag)
        
        $isTranslateOn.receive(on: DispatchQueue.main).sink { [unowned self] isOn in
            defaults.isTranslateOn = isOn
            if isOn {
                translate()
            }
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
        
        isTranslateOn = defaults.isTranslateOn
        text = defaults.text ?? ""
        selectedLanguageCode = defaults.selectedLanguageCode ?? selectedLanguageCode
        isTwitterOn = defaults.isTwitterOn
        isThreadsOn = defaults.isThreadsOn
        isTelegramOn = defaults.isTelegramOn
        
        // tasks
        
        Task {
//            await updateLanguages(try await dependencies.postServiceProvider.translateService.supportedLanguages)
            await updateLanguages([.english, .english, .english, .english, .english])
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
        
        if isThreadsOn {
            Task {
                try? await dependencies.postServiceProvider.twitterService.post(message: text)
            }
        }
        if isTwitterOn {
            Task {
                try? await dependencies.postServiceProvider.threadsService.post(message: text)
            }
        }
        if isTelegramOn {
            Task {
                try? await dependencies.postServiceProvider.telegramService.post(message: text)
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
//            let translated = try? await dependencies.postServiceProvider.translateService.translate(
//                text: text,
//                to: selectedLanguage
//            )
            await updateTranslation(string: text)// ?? "")
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
