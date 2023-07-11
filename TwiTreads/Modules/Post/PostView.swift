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
            
            TextField("Type your post here", text: $presenter.text)
                .focused($isFocused)
                .padding()
                .cornerRadius(10)
                .border(Color.black)
            
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
            
            Toggle("Twitter", isOn: $presenter.isTwitterOn)
            
            Toggle("Threads", isOn: $presenter.isThreadsOn)
            
            Button("Post", action: presenter.onPostTap)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView(
            presenter: PostPresenterImpl(
                dependencies: .init(
                    postServiceProvider: PostServiceProviderImpl(
                        dependencies: .init(
                            twitterService: PostServiceTwitter(),
                            threadsService: PostServiceThreads()
                        )
                    )
                )
            )
        )
    }
}

//#Preview {
//    PostView(
//        presenter: PostPresenterImpl(
//            dependencies: .init(
//                postServiceProvider: PostServiceProviderImpl(
//                    dependencies: .init(
//                        twitterService: PostServiceMock(),
//                        threadsService: PostServiceMock()
//                    )
//                )
//            )
//        )
//    )
//}
