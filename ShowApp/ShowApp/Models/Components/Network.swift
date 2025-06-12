//
//  Network.swift
//  ShowApp
//
//  Created by Bryan Zweiacker on 10.06.2025.
//

import Foundation

// MARK: - Network Models
struct Network: Codable {
    let id: Int?
    let name: String?
    let country: Country?
    let officialSite: String?
}

struct WebChannel: Codable {
    let id: Int?
    let name: String?
    let country: Country?
    let officialSite: String?
}
