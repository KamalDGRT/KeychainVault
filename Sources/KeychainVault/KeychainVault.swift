//
//  KeychainVault.swift
//  KeychainVault
//

import Foundation

open class KeychainVault {
    /// KeyPrefix: Prefix used to append to the account id.
    /// Such Prefix are best used when performing tests. Eg: test_account1_
    private var keyPrefix: String
    
    /// AccessGroup: Unique access group ID
    /// Used to sync data among same ID devices
    private var accessGroup: String
    
    /// Synchronizable: Bool which specifies if synchronizable data.
    /// When enabled all the keychains will be saved on the user's iCloud account.
    private var synchronizable: Bool
    
    /// ServiceName: Name of the keychain service.
    /// It can be the app's bundle ID (and often is)
    /// ✅ But it can also be any custom string
    /// 🧠 Use it to group related keychain items
    private var serviceName: String
    
    /// Unified initializer with default values
    /// /🧩 Analogy:
    /// `serviceName`--> `kSecAttrService` = category (e.g. "auth")
    /// `key`--> `kSecAttrAccount` = key (e.g. "user@example.com")
    /// `accessGroup` --> `kSecAttrAccessGroup` = which apps are allowed to see this
    public init(
        serviceName: String = "",
        keyPrefix: String = "",
        accessGroup: String = "",
        synchronizable: Bool = false
    ) {
        self.serviceName = serviceName
        self.keyPrefix = keyPrefix
        self.accessGroup = accessGroup
        self.synchronizable = synchronizable
    }
}

// MARK: Set Values
public extension KeychainVault {
    /// Store a `Bool` value
    func set(value: Bool, category: String, key: String) throws {
        let data = try JSONEncoder().encode(value)
        try set(value: data, for: category, with: key)
    }
    
    /// Store a `String` value
    func set(value: String, category: String, key: String) throws {
        guard let data = value.data(using: .utf8)
        else { throw KeychainError.encodingFailed }
        try set(value: data, for: category, with: key)
    }
    
    /// Store any Codable object
    func set<T: Codable>(object: T, category: String, key: String) throws {
        let data = try JSONEncoder().encode(object)
        try set(value: data, for: category, with: key)
    }
}

// MARK: Get Values
public extension KeychainVault {
    /// Retrieve a Bool value
    func getBool(for category: String, with keyName: String) throws -> Bool {
        let data = try getData(for: category, with: keyName)
        return try JSONDecoder().decode(Bool.self, from: data)
    }

    /// Retrieve a String value
    func getString(for category: String, with keyName: String) throws -> String {
        let data = try getData(for: category, with: keyName)
        return data.toString
    }

    /// Retrieve any Codable object
    func getObject<T: Codable>(
        for category: String,
        with keyName: String,
        as type: T.Type
    ) throws -> T {
        let data = try getData(for: category, with: keyName)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

public extension KeychainVault {
    func update(
        value: Data,
        for category: String,
        with keyName: String
    ) throws {
        let query: KeychainConstantDictionary = [
            .classType : kSecClassGenericPassword,
            .service   : category.anyObject,
            .account   : (keyPrefix + keyName).anyObject
        ]

        var attributesToUpdate: KeychainConstantDictionary = [
            .valueData      : value.anyObject,
            .dataProtection : kCFBooleanTrue,
            .protectionLevel: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        ]

        attributesToUpdate = addSyncIfRequired(
            queryItems: attributesToUpdate,
            isSynchronizable: synchronizable
        )

        let status = SecItemUpdate(query.cfDictionary, attributesToUpdate.cfDictionary)

        guard status != errSecItemNotFound
        else { throw KeychainError.itemNotFound }

        guard status == errSecSuccess
        else { throw KeychainError.unknown(status) }
    }
}

public extension KeychainVault {
    func delete(
        category: String,
        keyName: String
    ) throws {
        var query: KeychainConstantDictionary = [
            .classType : kSecClassGenericPassword,
            .service   : category.anyObject,
            .account   : (keyPrefix + keyName).anyObject
        ]
        
        query = addSyncIfRequired(
            queryItems: query,
            isSynchronizable: synchronizable
        )
        
        let status = SecItemDelete(query.cfDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound
        else { throw KeychainError.unknown(status) }
    }
}

private extension KeychainVault {
    func set(
        value: Data,
        for category: String,
        with keyName: String
    ) throws {
        do {
            try addItemToKeyChain(value: value, for: category, with: keyName)
        } catch KeychainError.duplicateEntry {
            try update(value: value, for: category, with: keyName)
        }
    }
    
    func addItemToKeyChain(
        value: Data,
        for category: String,
        with keyName: String
    ) throws {
        var query: KeychainConstantDictionary = [
            .classType      : kSecClassGenericPassword,
            .service        : category.anyObject,
            .account        : (keyPrefix + keyName).anyObject,
            .valueData      : value.anyObject,
            .dataProtection : kCFBooleanTrue,
            .protectionLevel: kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        ]
        
        query = addSyncIfRequired(
            queryItems: query,
            isSynchronizable: synchronizable
        )
        
        let status = SecItemAdd(query.cfDictionary, nil)
        
        guard status != errSecDuplicateItem
        else { throw KeychainError.duplicateEntry }
        
        guard status == errSecSuccess
        else { throw KeychainError.unknown(status) }
    }
    
    /// Core function to fetch raw data
    func getData(for category: String, with keyName: String) throws -> Data {
        var query: KeychainConstantDictionary = [
            .classType  : kSecClassGenericPassword,
            .service    : category.anyObject,
            .account    : (keyPrefix + keyName).anyObject,
            .returnData : kCFBooleanTrue,
            .matchLimit : kSecMatchLimitOne
        ]
        
        query = addSyncIfRequired(
            queryItems: query,
            isSynchronizable: synchronizable
        )
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query.cfDictionary, &result)
        
        guard status != errSecItemNotFound else { throw KeychainError.itemNotFound }
        guard status == errSecSuccess else { throw KeychainError.unknown(status) }
        
        guard let parsedData = result as? Data
        else { throw KeychainError.noData }
        
        return parsedData
    }
    
    /// Method to enable sync with iCloud
    func addSyncIfRequired(
        queryItems: KeychainConstantDictionary,
        isSynchronizable: Bool
    ) -> KeychainConstantDictionary {
        if isSynchronizable {
            var result = queryItems
            result[.accessGroup] = accessGroup.anyObject
            result[.synchronizable] = kCFBooleanTrue
            return result
        }
        return queryItems
    }
}
