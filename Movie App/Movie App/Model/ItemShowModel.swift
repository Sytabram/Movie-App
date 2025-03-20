//
//  ItemShowModel.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 11.03.2025.
//

import Foundation

struct ItemShowModel: Hashable {
    private let uniqueID = UUID()
    let id: Int
    let name: String
    let imageUrl: String?
    
    let summary: String?
    let rating: Double?
    let backgroundImageUrl: String?
    
    init(from show: ShowModel) {
        self.id = show.id
        self.name = show.name ?? "Unknown"
        self.imageUrl = show.image?.medium
        
        self.summary = show.summary
        self.rating = show.rating?.average
        self.backgroundImageUrl = show.image?.original
        
    }
}
