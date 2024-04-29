//
//  File.swift
//  
//
//  Created by KHJ on 2024/04/29.
//

import Foundation
import KeychainSwift

public class Keychain {
    public static let shared = Keychain()
    
    private let keychain = KeychainSwift()
     
    func setString(_ value: String, forKey key: String) {
        keychain.set(value, forKey: key)
    }
    
    func getString(forKey key: String) -> String? {
        return keychain.get(key)
    }
    
    func setBool(_ value: Bool, forKey key: String) {
        keychain.set(value, forKey: key)
    }
    
    func getBool(forKey key: String) -> Bool {
        return keychain.getBool(key) ?? false
    }
    
    func deleteString(forKey key: String) -> Bool {
        return keychain.delete(key)
    }
    
    func clear() -> Bool {
        return keychain.clear()
    }
}
