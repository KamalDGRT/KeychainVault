//
//  KeychainVault.swift
//  KeychainVault
//

import Foundation

open class KeychainVault {
    /// KeyPrefix: Prefix used to prepend to the `key`
    /// Such Prefixes are best used when performing tests. Eg: test_account1_
    private var keyPrefix: String
    
    /// AccessGroup: Unique access group ID
    /// Used to sync data among same ID devices
    private var accessGroup: String
    
    /// Synchronizable: Boolean which specifies if data is synchronizable data.
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
/// What these functions will do is, if there's no data earlier in the KeyChain, they will add one.
/// If any data is present in the specific category and key combination, it will update it.
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
    func getObject<T: Codable>(for category: String, with keyName: String) throws -> T {
        let data = try getData(for: category, with: keyName)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

public extension KeychainVault {
    /// Deletes a keychain item for the given category and key.
    ///
    /// - Parameters:
    ///   - category: The service/category under which the keychain item is stored.
    ///   - keyName: The specific key identifying the item (appended to the keyPrefix).
    /// - Throws: `KeychainError.unknown` if the deletion fails for an unknown reason.
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
    /// Saves or updates a keychain item with the given data.
    ///
    /// - Parameters:
    ///   - value: The data to store in the keychain.
    ///   - category: The service/category under which the keychain item is stored.
    ///   - keyName: The specific key identifying the item (appended to the keyPrefix).
    /// - Throws: A `KeychainError` if storing the data fails.
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
    
    /// Adds a new item to the keychain. Fails if the item already exists.
    ///
    /// - Parameters:
    ///   - value: The data to store in the keychain.
    ///   - category: The service/category under which the keychain item is stored.
    ///   - keyName: The specific key identifying the item (appended to the keyPrefix).
    /// - Throws:
    ///   - `KeychainError.duplicateEntry` if the item already exists.
    ///   - `KeychainError.unknown` if another error occurs.
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
    
    /// Updates an existing keychain item with new data.
    ///
    /// - Parameters:
    ///   - value: The new data to store.
    ///   - category: The service/category under which the keychain item is stored.
    ///   - keyName: The specific key identifying the item (appended to the keyPrefix).
    /// - Throws:
    ///   - `KeychainError.itemNotFound` if the item doesn’t exist.
    ///   - `KeychainError.unknown` if the update fails for another reason.
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
