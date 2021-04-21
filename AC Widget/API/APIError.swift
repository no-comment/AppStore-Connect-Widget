//
//  APIError.swift
//  AC Widget by NO-COMMENT
//

import Foundation

enum APIError: Error {
    case invalidCredentials
    case wrongPermissions
    case exceededLimit
    case noDataAvailable
    case notPublic
    case unknown

    var userDescription: String {
        switch self {
        case .invalidCredentials:
            return NSLocalizedString("ERROR_INVALID_CREDENTIALS", comment: "")
        case .wrongPermissions:
            return NSLocalizedString("ERROR_WRONG_PERMISSIONS", comment: "")
        case .exceededLimit:
            return NSLocalizedString("ERROR_EXCEEDED_LIMIT", comment: "")
        case .noDataAvailable:
            return NSLocalizedString("ERROR_NO_DATA_AVAILABLE", comment: "")
        case .unknown:
            return NSLocalizedString("ERROR_UNKNOWN", comment: "")
        case .notPublic:
            return "not public"
        }
    }
}
