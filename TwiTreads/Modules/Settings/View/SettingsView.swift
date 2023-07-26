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
                    Button("Connect Threads", action: presenter.onAddThreadsTap)
                        .padding()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .onAppear(perform: presenter.onAppear)
        .sheet(isPresented: $presenter.isLoginPresented) {
            LoginView(credentials: $presenter.credentials, onLoginTap: presenter.onLoginTap)
        }
    }
    
}
