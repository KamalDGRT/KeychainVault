//
//  KeychainVault.swift
//  KeychainVault
//

import Foundation

open class KeychainVault {
    /// KeyPrefix: Prefix used to append to the account id.
    /// Such Prefix are best used when performing tests. Eg: test_account1_
    private var keyPrefix: String = ""
    
    /// AccessGroup: Unique access group ID
    /// Used to sync data among same ID devices
    private var accessGroup: String = ""
    
    /// Synchronizable: Bool which specifies if synchronizable data.
    /// When enabled all the keychains will be saved on the users iCloud account.
    private var synchronizable: Bool = false
    
    private var serviceName: String = ""
    
    /// Initialiser to pre set KeyPrefix
    public init(keyPrefix: String) {
        self.keyPrefix = keyPrefix
    }
    
    /// Initialiser to pre set  access group and iCloud sync state of Keychain
    public init(
        accessGroup: String,
        synchronizable: Bool
    ) {
        self.accessGroup = accessGroup
        self.synchronizable = synchronizable
    }
    
    /// Initialiser to pre set keyPrefix, access group and sync state of Keychain
    public init(
        keyPrefix: String,
        accessGroup: String,
        synchronizable: Bool
    ) {
        self.keyPrefix = keyPrefix
        self.accessGroup = accessGroup
        self.synchronizable = synchronizable
    }
    
    public init(serviceName: String) {
        self.serviceName = serviceName
    }
    
    /// Empty Initialiser to use generic keyChain
    public init() {}
}
