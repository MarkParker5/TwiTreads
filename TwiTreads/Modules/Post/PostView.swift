//
//  PostView.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation
import SwiftUI

struct PostView: View {
    @AnyStateObject var presenter: any PostPresenter
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack {
            
            header
            
            Divider()
            
            main
                .padding(.horizontal)
                .animation(.easeInOut, value: presenter.isTranslateOn)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
    
    @ViewBuilder
    private var header: some View {
        HStack {
            
            Button("Cancel") {
                isFocused = false
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
            
            Text("New Post")
                .font(.title3)
            
            Spacer()
                .frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    private var main: some View {
        TextField("Type your post here", text: $presenter.text, axis: .vertical)
            .focused($isFocused)
            .lineLimit(1...5)
            .padding()
        
        HStack {
            Toggle("Translate", isOn: $presenter.isTranslateOn)
                .fixedSize()
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if presenter.isTranslateOn {
                languages
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        
        if presenter.isTranslateOn {
            TextField("Translated text will be here", text: $presenter.translatedText, axis: .vertical)
                .lineLimit(1...5)
                .padding()
                .transition(.move(edge: .trailing).combined(with: .opacity))
        }
        
        Spacer()
        
        Toggle("Twitter", isOn: $presenter.isTwitterOn)
        
        Toggle("Threads", isOn: $presenter.isThreadsOn)
        
        Toggle("Telegram", isOn: $presenter.isTelegramOn)
        
        Button("Post", action: presenter.onPostTap)
            .padding(.vertical)
    }
    
    @ViewBuilder
    private var languages: some View {
        Menu {
            ForEach(presenter.languages) { language in
                Button("Language") {
                    presenter.onLanguageTap(language)
                }
            }
        } label: {
            Text(presenter.selectedLanguage.name)
        }
    }
}

struct PostView_Previews: PreviewProvider {
    class PostPresenterMock: PostPresenter, ObservableObject {
        var translatedText: String = ""
        var selectedLanguage: Language = .english
        var languages: [Language] = []
        var isTranslateOn: Bool = true
        var text: String = ""
        var isTwitterOn: Bool = true
        var isThreadsOn: Bool = true
        var isTelegramOn: Bool = true
        func onLanguageTap(_ language: Language) {}
        func onPostTap() {}
    }
    
    static var previews: some View {
        PostView(
            presenter: PostPresenterMock()
        )
    }
}
