//
//  APIError.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 14.11.2024.
//

import Foundation

// MARK: - API Error Types
enum APIError: Error {
    case invalidURL
    case unauthorized
    case networkError
    case notFound
    case requestFailed
}
