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
    
    var genres: [String]? = []
    let status: String?
    let runtime: Int?
    let premiered: String?
    let ended: String?
    let network: String?
    let officialSite: String?
    
    var scheduleDays: [String] = []
    var scheduleTime: String? = nil
    
    let imdb: String?
    
    init(from show: ShowModel) {
        self.id = show.id
        self.name = show.name ?? "Unknown"
        self.imageUrl = show.image?.medium
        
        self.summary = show.summary
        self.rating = show.rating?.average
        self.backgroundImageUrl = show.image?.original
        
        self.genres = show.genres ?? []
        self.status = show.status
        self.runtime = show.runtime
        self.premiered = show.premiered
        self.ended = show.ended
        self.network = show.network?.name
        self.officialSite = show.officialSite
        
        self.scheduleDays = show.schedule?.days ?? []
        self.scheduleTime = show.schedule?.time
        self.imdb = show.externals?.imdb ?? nil
    }
}
