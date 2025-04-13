//
 //  CFString+Extension.swift
 //  KeychainVault
 //

import Foundation

public typealias KeychainConstantDictionary = [KeychainConstant: AnyObject]

public extension CFString {
    var stringValue: String {
        return self as String
    }
}

public extension KeychainConstantDictionary {
    var cfDictionary: CFDictionary {
        let query: [String: AnyObject] = reduce(
            into: [String: AnyObject]()
        ) { result, header in
            result[header.key.keyName] = header.value
        }
        return query as CFDictionary
    }
}

public extension String {
    var anyObject: AnyObject {
        self as AnyObject
    }
}

public extension Data {
    var anyObject: AnyObject {
        self as AnyObject
    }
    
    var toString: String {
        return String(data: self, encoding: .utf8) ?? ""
    }
}
