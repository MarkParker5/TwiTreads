//
//  TabBarView.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation
import SwiftUI

struct TabBarView: View {
    @AnyStateObject var presenter: any TabBarPresenter
    
    var body: some View {
        TabView(selection: $presenter.selectedTab) {
            
            FeedView(presenter: presenter.feedPresenter)
                .tabItem {
                    Image(systemName: "house")
                    Text("Feed")
                }
                .tag(TabBarScreen.feed)
            
            PostView(presenter: presenter.postPresenter)
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Post")
                }
                .tag(TabBarScreen.post)
            
            SettingsView(presenter: presenter.settingsPresenter)
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(TabBarScreen.settings)
        }
    }
}
