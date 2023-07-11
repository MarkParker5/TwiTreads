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
        Text("Feed")
    }
}
