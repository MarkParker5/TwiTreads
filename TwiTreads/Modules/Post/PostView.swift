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
    
    var body: some View {
        Text("Post View")
    }
}
