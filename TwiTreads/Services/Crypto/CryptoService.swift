//
//  CryptoService.swift
//  TwiTreads
//
//  Created by Mark Parker on 21/07/2023.
//

import Foundation
import CryptoKit

protocol CryptoService {
    
    func encryptRSA(string: String, publicKey: String) -> String?
    
    func sha256(string: String, prefix: Int?) -> String
}

extension CryptoService {
    func sha256(string: String) -> String {
        sha256(string: string, prefix: nil)
    }
}

// MARK: - CryptoServiceImpl

class CryptoServiceImpl: CryptoService {
    
    func encryptRSA(string: String, publicKey: String) -> String? {
        let keyString = publicKey.replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----\n", with: "").replacingOccurrences(of: "\n-----END PUBLIC KEY-----", with: "")
        guard let data = Data(base64Encoded: keyString) else { return nil }
        
        var attributes: CFDictionary {
            return [kSecAttrKeyType         : kSecAttrKeyTypeRSA,
                    kSecAttrKeyClass        : kSecAttrKeyClassPublic,
                    kSecAttrKeySizeInBits   : 2048,
                    kSecReturnPersistentRef : kCFBooleanTrue] as CFDictionary
        }
        
        var error: Unmanaged<CFError>? = nil
        guard let secKey = SecKeyCreateWithData(data as CFData, attributes, &error) else {
            print(error.debugDescription)
            return nil
        }
        return encrypt(string: string, publicKey: secKey)
    }
    
    func encrypt(string: String, publicKey: SecKey) -> String? {
        let buffer = [UInt8](string.utf8)
        
        var keySize   = SecKeyGetBlockSize(publicKey)
        var keyBuffer = [UInt8](repeating: 0, count: keySize)
        
        // Encrypto  should less than key length
        guard SecKeyEncrypt(publicKey, SecPadding.PKCS1, buffer, buffer.count, &keyBuffer, &keySize) == errSecSuccess else { return nil }
        return Data(bytes: keyBuffer, count: keySize).base64EncodedString()
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
