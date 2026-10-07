//
//  KeychainManager.swift
//  WeCMS_iOS
//
//  Native Keychain wrapper replacing KeychainSwift dependency.
//

import Security

enum KeychainManager {

    // MARK: - Version-specific credential helpers
    // Originally appended the active product name to keep WABOOKS KH, WABOOKS VN and
    // WeCMS credentials separate on a shared device. Only WeCMS ships now, so the value
    // is fixed — but it MUST stay exactly "_WeCMS": it is part of the keychain key, so
    // changing it would orphan the saved credentials of every existing user.

    private static let credentialSuffix = "_WeCMS"

    @discardableResult
    static func setCredential(_ value: String, forKey key: String) -> Bool {
        set(value, forKey: key + credentialSuffix)
    }

    static func getCredential(_ key: String) -> String? {
        get(key + credentialSuffix)
    }

    @discardableResult
    static func deleteCredential(_ key: String) -> Bool {
        delete(key + credentialSuffix)
    }



    @discardableResult
    static func set(_ value: String, forKey key: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        let attributes: [String: Any] = [kSecValueData as String: data]
        // Try updating first; if not found, add new
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = query
            addQuery[kSecValueData as String] = data
            return SecItemAdd(addQuery as CFDictionary, nil) == errSecSuccess
        }
        return status == errSecSuccess
    }

    static func get(_ key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    @discardableResult
    static func delete(_ key: String) -> Bool {
        guard !key.isEmpty else { return false }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
}
