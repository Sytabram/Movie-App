//
//  ShowCategory.swift
//  ShowApp
//
//  Created by Bryan Zweiacker on 02.04.2024.
//

import Foundation

// MARK: - Show Category Model
struct ShowCategory: Codable {
    let name: String
    var showIDs: [String]
}

// MARK: - Mock Data
let mockShowCategories: [ShowCategory] = [
    ShowCategory(name: NSLocalizedString("categoryRecommended", comment: ""), showIDs: ["53647", "41074", "60", "38963", "30", "31683"]),
    ShowCategory(name: NSLocalizedString("categoryPopular", comment: ""), showIDs: ["169", "7103", "38963", "53647"]),
    ShowCategory(name: NSLocalizedString("categoryHorror", comment: ""), showIDs: ["53647", "1791", "30", "31683"]),
    ShowCategory(name: NSLocalizedString("categoryCrime", comment: ""), showIDs: ["60", "32158", "21532"]),
    ShowCategory(name: NSLocalizedString("categoryDocumentary", comment: ""), showIDs: ["41074", "33952", "13644", "7103"])
]
