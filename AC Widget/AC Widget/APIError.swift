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
    
    var userDescription: String {
        switch self {
        case .invalidCredentials:
            return "The credentials you entered are incorrect."
        case .wrongPermissions:
            return "Your API-key does not have the right permissions."
        case .exceededLimit:
            return "You have exceeded the daily limit of API requests."
        }
    }
}
