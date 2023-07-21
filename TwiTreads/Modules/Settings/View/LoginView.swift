//
//  LoginView.swift
//  TwiTreads
//
//  Created by Mark Parker on 21/07/2023.
//

import SwiftUI

struct LoginView: View {
    
    @Binding var credentials: Credentials
    var onLoginTap: () -> Void
    
    var body: some View {
        VStack {
            Spacer()
            
            TextField("Username", text: $credentials.username)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
            
            SecureField("Password", text: $credentials.password)
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color(.tertiarySystemBackground))
                .cornerRadius(10)
            
            Button("Login", action: onLoginTap)
                .padding()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .background(Color.background)
    }
}
