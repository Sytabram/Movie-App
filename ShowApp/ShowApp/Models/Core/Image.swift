//
//  Image.swift
//  ShowApp
//
//  Created by Bryan Zweiacker on 05.04.2024.
//

import Foundation

// MARK: - Image Model
struct Image: Codable {
    let id: Int
    let type: String
    let isMain: Bool
    let resolutions: ImageResolutions
    
    private enum CodingKeys: String, CodingKey {
        case id, type, resolutions
        case isMain = "main"
    }
}

// MARK: - Image Supporting Types
struct ImageResolutions: Codable {
    let original: ImageResolution
    let medium: ImageResolution?
}

struct ImageResolution: Codable {
    let url: String
    let width: Int
    let height: Int
}
