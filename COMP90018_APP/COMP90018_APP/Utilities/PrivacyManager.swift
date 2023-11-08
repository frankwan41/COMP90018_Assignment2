//
//  PrivacyManager.swift
//  COMP90018_APP
//
//  Created by Junran Lin on 8/11/2023.
//

import Foundation
import CryptoKit

class PrivacyManager{
    
    static func encryptMessage(_ message: String, with password: String) -> String {
        guard let messageData = message.data(using: .utf8) else {
            fatalError("Failed to convert message to Data")
        }
        
        // Use SHA256 hash of the password to create a symmetric key
        let passwordHash = SHA256.hash(data: password.data(using: .utf8)!)
        let symmetricKey = SymmetricKey(data: passwordHash)
        
        do {
            let sealedBox = try AES.GCM.seal(messageData, using: symmetricKey)
            
            let ciphertextString = sealedBox.ciphertext.base64EncodedString()
            let nonceString = sealedBox.nonce.withUnsafeBytes { Data(Array($0)).base64EncodedString() }
            let tagString = sealedBox.tag.base64EncodedString()
            
            let combinedString = "\(ciphertextString):\(nonceString):\(tagString)"
            
            return combinedString
        } catch {
            print("Encryption failed: \(error)")
            return ""
        }
    }
    
    static func decryptMessage(_ combinedString: String, with password: String) -> String {
        let components = combinedString.split(separator: ":").map(String.init)
        guard components.count == 3,
              let ciphertext = Data(base64Encoded: components[0]),
              let nonce = Data(base64Encoded: components[1]),
              let tag = Data(base64Encoded: components[2]) else {
            print("Invalid format for the encrypted data")
            return ""
        }
        
        // Use SHA256 hash of the password to recreate the symmetric key
        let passwordHash = SHA256.hash(data: password.data(using: .utf8)!)
        let symmetricKey = SymmetricKey(data: passwordHash)
        
        do {
            let sealedBox = try AES.GCM.SealedBox(nonce: .init(data: nonce), ciphertext: ciphertext, tag: tag)
            let decryptedData = try AES.GCM.open(sealedBox, using: symmetricKey)
            
            guard let decryptedString = String(data: decryptedData, encoding: .utf8) else {
                print("Failed to decrypt or decode data")
                return ""
            }
            
            return decryptedString
        } catch {
            print("Decryption failed: \(error)")
            return ""
        }
    }
    
    
}
