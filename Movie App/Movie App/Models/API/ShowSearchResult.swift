//
//  ShowSearchResult.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 06.04.2024.
//

import Foundation

// MARK: - Search Result Model
struct ShowSearchResult: Codable {
    let score: Double
    let show: Show
}
