//
 //  KeychainError.swift
 //  KeychainVault
 //

import Foundation

public enum KeychainError: Error {
    case invalidKey
    case noData
    case itemNotFound
    case duplicateEntry
    case encodingFailed
    case unknown(OSStatus)
    case noPassword
}
