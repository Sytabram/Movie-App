//
//  Show.swift
//  ShowApp
//
//  Created by Bryan Zweiacker on 01.04.2024.
//

import Foundation

// MARK: - Main Show Model
struct Show: Codable {
    let id: Int
    let url: String?
    let name: String
    let type: String?
    let language: String?
    let genres: [String]?
    let status: String?
    let runtime: Int?
    let averageRuntime: Int?
    let premiered: String?
    let ended: String?
    let officialSite: String?
    let schedule: Schedule?
    let rating: Rating?
    let weight: Int?
    let network: Network?
    let webChannel: WebChannel?
    let dvdCountry: DVDCountry?
    let externals: Externals?
    let image: ShowImage?
    let summary: String?
    let updated: Int?
    let links: ShowLinks?
    
    private enum CodingKeys: String, CodingKey {
        case id, url, name, type, language, genres, status, runtime
        case averageRuntime, premiered, ended, officialSite, schedule
        case rating, weight, network, webChannel, dvdCountry, externals
        case image, summary, updated
        case links = "_links"
    }
}
