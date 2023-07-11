//
//  RootView.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation
import SwiftUI

struct RootView: View {
    @AnyStateObject var presenter: any RootPresenter
    
    var body: some View {
        switch presenter.rootScreen {
        case .tabBar:
            TabBarView(presenter: presenter.tabBarPresenter)
        }
    }
}
