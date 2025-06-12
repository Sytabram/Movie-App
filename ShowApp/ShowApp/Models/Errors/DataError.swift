//
//  DataError.swift
//  ShowApp
//
//  Created by Bryan Zweiacker on 14.11.2024.
//

import Foundation

// MARK: - Data Processing Error Types
enum DataError: Error {
    case decodingError
    case isEmpty
    case imageBackgroundEmpty
}
