//
//  PostService.swift
//  TwiTreads
//
//  Created by Mark Parker on 11/07/2023.
//

import Foundation

protocol PostService {
    
    func post(message: String) async throws
}
