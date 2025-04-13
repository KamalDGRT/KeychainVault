//
//  KeychainStatusError.swift
//  KeychainVault
//

import Foundation

public enum KeychainStatusError {
    case authFailed
    case noSuchKeychain
    case duplicateKeychain
    case duplicateItem
    case duplicateCallback
    case invalidKeychain
    case invalidItemRef
    case invalidCallback
    case invalidAuthority
    case invalidCertAuthority
    case interactionRequired
    case dataNotAvailable
    case dataNotModifiable
    case notAvailable
    case notSigner
    case notTrusted
    case noDefaultKeychain
    case noDefaultAuthority
    case noPolicyModule
    case noTrustSettings
    case certificateExpired
    case certificateRevoked
    case certificateSuspended
    case certificateNotValidYet
    case certificateCannotOperate
    case itemNotFound
    case unknown(OSStatus)
}

public extension KeychainStatusError {
    var message: String {
        switch self {
        case .authFailed:
            return "Authorization and/or authentication failed."
        case .noSuchKeychain:
            return "The keychain does not exist."
        case .duplicateKeychain:
            return "A keychain with the same name already exists."
        case .duplicateItem:
            return "The item already exists."
        case .duplicateCallback:
            return "The callback is not valid."
        case .invalidKeychain:
            return "The keychain is not valid."
        case .invalidItemRef:
            return "The item reference is invalid."
        case .invalidCallback:
            return "The callback is not valid."
        case .invalidAuthority:
            return "The authority is not valid."
        case .invalidCertAuthority:
            return "The certificate authority is not valid."
        case .interactionRequired:
            return "User interaction is required."
        case .dataNotAvailable:
            return "The data is not available."
        case .dataNotModifiable:
            return "The data is not modifiable."
        case .notAvailable:
            return "No trust results are available."
        case .notSigner:
            return "The certificate is not signed by its proposed parent."
        case .notTrusted:
            return "The trust policy is not trusted."
        case .noDefaultKeychain:
            return "A default keychain does not exist."
        case .noDefaultAuthority:
            return "No default authority was detected."
        case .noPolicyModule:
            return "There is no policy module available."
        case .noTrustSettings:
            return "No trust settings were found."
        case .certificateExpired:
            return "An expired certificate was detected."
        case .certificateRevoked:
            return "The certificate was revoked."
        case .certificateSuspended:
            return "The certificate was suspended."
        case .certificateNotValidYet:
            return "The certificate is not yet valid."
        case .certificateCannotOperate:
            return "The certificate cannot operate."
        case .itemNotFound:
            return "The item cannot be found."
        case .unknown(let statusCode):
            return "An unknown error occurred. The status code is \(statusCode)"
        }
    }
}

public struct ErrorMapper {
    public static func getKeychainStatusError(from status: OSStatus) -> KeychainStatusError {
        switch status {
        case errSecAuthFailed: return .authFailed
        case errSecNoSuchKeychain: return .noSuchKeychain
        case errSecDuplicateKeychain: return .duplicateKeychain
        case errSecDuplicateItem: return .duplicateItem
        case errSecDuplicateCallback: return .duplicateCallback
        case errSecInvalidKeychain: return .invalidKeychain
        case errSecInvalidItemRef: return .invalidItemRef
        case errSecInvalidCallback: return .invalidCallback
        case errSecInvalidAuthority: return .invalidAuthority
        case errSecInvalidCertAuthority: return .invalidCertAuthority
        case errSecInteractionRequired: return .interactionRequired
        case errSecDataNotAvailable: return .dataNotAvailable
        case errSecDataNotModifiable: return .dataNotModifiable
        case errSecNotAvailable: return .notAvailable
        case errSecNotSigner: return .notSigner
        case errSecNotTrusted: return .notTrusted
        case errSecNoDefaultKeychain: return .noDefaultKeychain
        case errSecNoDefaultAuthority: return .noDefaultAuthority
        case errSecNoPolicyModule: return .noPolicyModule
        case errSecNoTrustSettings: return .noTrustSettings
        case errSecCertificateExpired: return .certificateExpired
        case errSecCertificateRevoked: return .certificateRevoked
        case errSecCertificateSuspended: return .certificateSuspended
        case errSecCertificateNotValidYet: return .certificateNotValidYet
        case errSecCertificateCannotOperate: return .certificateCannotOperate
        case errSecItemNotFound: return .itemNotFound
        default: return .unknown(status)
        }
    }
}
