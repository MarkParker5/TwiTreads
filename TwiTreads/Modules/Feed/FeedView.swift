//
//  FeedView.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation
import SwiftUI

struct FeedView: View {
    @AnyStateObject var presenter: any FeedPresenter
    
    var body: some View {
        Text("Feed is not implemented yet :(\nFeel free to contribute to [MarkParker5/TwiTreads](https://github.com/MarkParker5/TwiTreads)! on GitHub")
            .multilineTextAlignment(.center)
            .padding()
    }
}
