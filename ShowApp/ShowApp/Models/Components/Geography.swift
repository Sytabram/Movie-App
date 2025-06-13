//
//  Geography.swift
//  ShowApp
//
//  Created by Bryan Zweiacker on 10.06.2025.
//

import Foundation

// MARK: - Geographic Models
struct Country: Codable {
    let name: String?
    let code: String?
    let timezone: String?
}

// MARK: - Type Aliases
typealias DVDCountry = Country
