//
 //  CFString+Extension.swift
 //  KeychainVault
 //

import Foundation

/// A typealias representing a dictionary used to build Keychain queries.
/// Keys are `KeychainConstant`, and values are `AnyObject` for compatibility with CoreFoundation.
public typealias KeychainConstantDictionary = [KeychainConstant: AnyObject]

public extension CFString {
    /// Converts a `CFString` to a Swift `String`.
    var stringValue: String {
        return self as String
    }
}

public extension KeychainConstantDictionary {
    /// Converts a `KeychainConstantDictionary` into a `CFDictionary`, suitable for use with Keychain APIs.
    ///
    /// This transforms each `KeychainConstant` key into its corresponding raw key name string (`keyName`)
    /// and prepares a properly typed dictionary for Keychain operations.
    var cfDictionary: CFDictionary {
        let query: [String: AnyObject] = reduce(
            into: [String: AnyObject]()
        ) { result, header in
            result[header.key.keyName] = header.value
        }
        return query as CFDictionary
    }
}

extension String {
    /// A convenience property to cast a `String` into `AnyObject`, used for Keychain dictionary values.
    var anyObject: AnyObject {
        self as AnyObject
    }
}

extension Data {
    /// A convenience property to cast `Data` into `AnyObject`, used for Keychain dictionary values.
    var anyObject: AnyObject {
        self as AnyObject
    }
    
    /// Converts `Data` into a UTF-8 `String`, or an empty string if decoding fails.
    var toString: String {
        return String(data: self, encoding: .utf8) ?? ""
    }
}
