//
//  LoginView.swift
//  TwiTreads
//
//  Created by Mark Parker on 21/07/2023.
//

import SwiftUI

struct LoginView: View {
    
    @Binding var credentials: Credentials
    var usernameTitle: String = "Username"
    var passwordTitle: String = "Password"
    var message: String = ""
    var onLoginTap: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField(usernameTitle, text: $credentials.username)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
            
            SecureField(passwordTitle, text: $credentials.password)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
            
            Text(message)
                .padding()
            
            Button("Login", action: onLoginTap)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.background)
    }
}
