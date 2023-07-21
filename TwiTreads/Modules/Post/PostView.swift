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
    @FocusState var isFocused: Bool
    
    var body: some View {
        VStack {
            
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
            
            Divider()
            
            Group {
                TextField("Type your post here", text: $presenter.text, axis: .vertical)
                    .focused($isFocused)
                    .lineLimit(1...5)
                    .padding()
                
                /*
                 HStack {
                 Toogle(isOn: .constant(false), label: "Translate")
                 Menu {
                 ForEach(presenter.language) { language in
                 Text(language.name)
                 }
                 } label: {
                 Button("Language") {
                 presenter.onLanguageTap(language)
                 }
                 }
                 }
                 Text(presenter.translatedText)
                 */
                
                Spacer()
                
                Toggle("Twitter", isOn: $presenter.isTwitterOn)
                
                Toggle("Threads", isOn: $presenter.isThreadsOn)
                
                Button("Post", action: presenter.onPostTap)
                    .padding(.vertical)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
}

struct PostView_Previews: PreviewProvider {
    class PostPresenterMock: PostPresenter, ObservableObject {
        var text: String = ""
        var isTwitterOn: Bool = true
        var isThreadsOn: Bool = true
        func onPostTap() {}
    }
    
    static var previews: some View {
        PostView(
            presenter: PostPresenterMock()
        )
    }
}
