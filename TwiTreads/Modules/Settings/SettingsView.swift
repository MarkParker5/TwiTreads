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
            
            Button("Connect Threads", action: presenter.onAddThreadsTap)
                .padding()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
    }
    
}
