//
//  APIError.swift
//  AC Widget by NO-COMMENT
//

import Foundation

enum APIError: Error {
    case noKeySelected
    case invalidCredentials
    case wrongPermissions
    case exceededLimit
    case noDataAvailable
    case unhandled(String)
    case unknown

    var userTitle: String {
        switch self {
        case .invalidCredentials:
            return "Invalid Key"
        case .wrongPermissions:
            return "No Permission"
        case .exceededLimit:
            return "Limit Reached"
        case .noDataAvailable:
            return "No Data Available"
        case .noKeySelected:
            return "No Key Selected"
        case .unknown:
            return "Unknown Error"
        case .unhandled:
            return "Unhandled Error"
        }
    }

    var userDescription: String {
        switch self {
        case .invalidCredentials:
            return "The credentials you entered are incorrect."
        case .wrongPermissions:
            return "Your API-key does not have the right permissions."
        case .exceededLimit:
            return "You have exceeded the hourly limit of API requests."
        case .noDataAvailable:
            return "Data is not yet available."
        case .noKeySelected:
            return "You have not selected a key."
        case .unknown:
            return "An unknown error occurred. Please file a bug report."
        case .unhandled(let description):
            return "Error: \(description)"
        }
    }
}
