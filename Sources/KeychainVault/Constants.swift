//
//  Constants.swift
//  KeychainVault
//

import Foundation

/// Wrapper for keychain constants
public enum KeychainConstant {
    case classType
    case service
    case account
    case valueData
    case returnData
    case returnReference
    case returnAttributes
    case matchLimit
    case accessGroup
    case server
    case synchronizable
    case dataProtection
    case internetPassword
    case genericPassword
    case protectionLevel
    
    public var keyName: String {
        switch self {
        case .classType:
            return kSecClass.stringValue
        case .service:
            return kSecAttrService.stringValue
        case .account:
            return kSecAttrAccount.stringValue
        case .valueData:
            return kSecValueData.stringValue
        case .returnData:
            return kSecReturnData.stringValue
        case .returnReference:
            return kSecReturnRef.stringValue
        case .returnAttributes:
            return kSecReturnAttributes.stringValue
        case .matchLimit:
            return kSecMatchLimit.stringValue
        case .accessGroup:
            return kSecAttrAccessGroup.stringValue
        case .server:
            return kSecAttrServer.stringValue
        case .synchronizable:
            return kSecAttrSynchronizable.stringValue
        case .dataProtection:
            return kSecUseDataProtectionKeychain.stringValue
        case .internetPassword:
            return kSecClassInternetPassword.stringValue
        case .genericPassword:
            return kSecClassGenericPassword.stringValue
        case .protectionLevel:
            return kSecAttrAccessible.stringValue
        }
    }
}
