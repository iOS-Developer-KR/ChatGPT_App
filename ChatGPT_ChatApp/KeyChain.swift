//
//  KeyChain.swift
//  ChatGPT_ChatApp
//
//  Created by Taewon Yoon on 6/1/24.
//

import Foundation

enum KeychainError: Error {
    case unhandledError(status: OSStatus)
    case noPassword
    case unexpectedTokenData
}

@Observable
class KeyChain {

    static let shared = KeyChain()
    
    var exist: Bool = false
    
    func saveToken(token: String) throws {
        let tokenData = Data(token.utf8)
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, // keychain Item Class
                                    kSecAttrService as String: "openAI_Token",
                                    kSecValueData as String: tokenData] // 저장할 아이템의 데이터
        
        // 먼저 기존 항목이 있는지 확인하고 있으면 업데이트합니다.
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecDuplicateItem {
            // 기존 항목이 있는 경우 업데이트합니다.
            let attributesToUpdate: [String: Any] = [kSecValueData as String: tokenData]
            let updateQuery: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                              kSecAttrService as String: "openAI_Token"]
            
            let updateStatus = SecItemUpdate(updateQuery as CFDictionary, attributesToUpdate as CFDictionary)
            guard updateStatus == errSecSuccess else { throw KeychainError.unhandledError(status: updateStatus) }
        } else {
            // 기존 항목이 없는 경우 추가합니다.
            guard status == errSecSuccess else { throw KeychainError.unhandledError(status: status) }
        }
    }
    
    func removeToken() throws {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword, // keychain Item Class
                                    kSecAttrService as String: "openAI_Token"]
        
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
        exist = false
    }
    
    @discardableResult
    func getToken() -> Bool {
        let query: [String: Any] = [kSecClass as String: kSecClassGenericPassword,
                                    kSecAttrService as String: "openAI_Token",
                                    kSecMatchLimit as String: kSecMatchLimitOne,
                                    kSecReturnAttributes as String: true,
                                    kSecReturnData as String: true]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { return false }
        guard status == errSecSuccess else { return false }
        
        guard let existingItem = item as? [String : Any],
            let tokenData = existingItem[kSecValueData as String] as? Data,
            let _ = String(data: tokenData, encoding: String.Encoding.utf8)
        else {
            return false
        }
        exist = true
        return true
    }
    
}
