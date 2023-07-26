//
//  SettingsView.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @AnyStateObject var presenter: any SettingsPresenter
    
    var body: some View {
        VStack {
            
            if presenter.isLoading {
                ProgressView()
            } else {
                
                if let user = presenter.twitterUser {
                    Text("Twitter connected as @\(user.username)")
                        .padding()
                } else {
                    Button("Connect Twitter", action: presenter.onAddTwitterTap)
                        .padding()
                }
                
                if let user = presenter.threadsUser {
                    Text("Threads connected as @\(user.username)")
                        .padding()
                } else {
                    Button("Connect Threads\nusing Instagram credentials", action: presenter.onAddThreadsTap)
                        .padding()
                }
                
                if let user = presenter.telegramUser {
                    Text("Telegram connected as \(user.username)")
                        .padding()
                } else {
                    Button("Connect Telegram Channel", action: presenter.onAddTelegramTap)
                        .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .onAppear(perform: presenter.onAppear)
        .sheet(item: $presenter.presentedSheet) { item in
            LoginView(
                credentials: $presenter.credentials,
                usernameTitle: item == .telegramLogin ? "Channel name (with @)" : "Username",
                passwordTitle: item == .telegramLogin ? "Bot token" : "Password",
                message: item == .threadsLogin
                ? "2FA is not supported yet, you need to disable it to use TwiTreads"
                : "Create a bot using @BotFather, save the bot token and add the bot as an admin to your channel",
                onLoginTap: presenter.onLoginTap
            )
        }
    }
}
