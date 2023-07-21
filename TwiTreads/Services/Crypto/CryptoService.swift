//
//  CryptoService.swift
//  TwiTreads
//
//  Created by Mark Parker on 21/07/2023.
//

import Foundation
import CryptoKit
import SwiftyRSA

protocol CryptoService {
    
    func encryptRSA(string: String, publicKey: String) throws -> String
    
    func sha256(string: String, prefix: Int?) -> String
}

extension CryptoService {
    func sha256(string: String) -> String {
        sha256(string: string, prefix: nil)
    }
}

// MARK: - CryptoServiceImpl

class CryptoServiceImpl: CryptoService {
    
    func encryptRSA(string: String, publicKey: String) throws -> String {
        guard
            let publicKeyData = Data(base64Encoded: publicKey),
            let publicKeyPem = String(data: publicKeyData, encoding: .utf8)
        else {
            throw NSError(domain: "CryptoService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Could not create public key from base64 string"])
        }
        
        let publicKey = try PublicKey(pemEncoded: publicKeyPem)
        let clear = try ClearMessage(string: string, using: .utf8)
        return try clear.encrypted(with: publicKey, padding: .PKCS1).base64String
    }
    
    func sha256(string: String, prefix: Int?) -> String {
        let data = string.data(using: .utf8)!
        let digest = SHA256.hash(data: data)
        var bytes = Array(digest.makeIterator())
        if let prefix {
            bytes = Array(bytes.prefix(prefix))
        }
        return bytes.map { String(format: "%02X", $0) }.joined()
    }
}
