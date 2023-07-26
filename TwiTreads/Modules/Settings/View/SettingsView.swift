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
            Button("Connect Twitter", action: presenter.onAddTwitterTap)
                .padding()
                .disabled(presenter.isTwitterLoggedIn)
                .opacity(presenter.isTwitterLoggedIn ? 0.3 : 1)
            
            Button("Connect Threads", action: presenter.onAddThreadsTap)
                .padding()
                .disabled(presenter.isThreadsLoggedIn)
                .opacity(presenter.isThreadsLoggedIn ? 0.3 : 1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .onAppear(perform: presenter.onAppear)
        .sheet(isPresented: $presenter.isLoginPresented) {
            LoginView(credentials: $presenter.credentials, onLoginTap: presenter.onLoginTap)
        }
    }
    
}
