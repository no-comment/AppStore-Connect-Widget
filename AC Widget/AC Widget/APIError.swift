//
//  APIError.swift
//  AC Widget
//
//  Created by Cameron Shemilt on 01.04.21.
//

import Foundation

enum APIError: Error {
    case invalidCredentials
    case wrongPermissions
    case exceededLimit
    case unknown
    
    var userDescription: String {
        switch self {
        case .invalidCredentials:
            return NSLocalizedString("ERROR_INVALID_CREDENTIALS", comment: "")
        case .wrongPermissions:
            return NSLocalizedString("ERROR_WRONG_PERMISSIONS", comment: "")
        case .exceededLimit:
            return NSLocalizedString("ERROR_EXCEEDED_LIMIT", comment: "")
        case .unknown:
            return NSLocalizedString("ERROR_UNKNOWN", comment: "")
        }
    }
}
