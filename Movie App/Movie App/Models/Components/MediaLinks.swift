//
//  MediaLinks.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 10.06.2025.
//

import Foundation

// MARK: - Media Models
struct ShowImage: Codable {
    let medium: String?
    let original: String?
}

// MARK: - Link Models
struct ShowLinks: Codable {
    let `self`: SelfLink?
    let previousEpisode: PreviousEpisode?
}

struct SelfLink: Codable {
    let href: String?
}

struct PreviousEpisode: Codable {
    let href: String?
    let name: String?
}
