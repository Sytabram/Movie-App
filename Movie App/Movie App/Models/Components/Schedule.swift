//
//  Schedule.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 10.06.2025.
//

import Foundation

// MARK: - Schedule Model
struct Schedule: Codable {
    let time: String?
    let days: [String]?
}
