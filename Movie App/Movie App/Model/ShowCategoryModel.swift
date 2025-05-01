//
//  ShowCategoryModel.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 02.04.2024.
//

import Foundation

struct ShowCategoryModel: Codable
{
    var name: String
    var showsID: [String]
}

let mockShowCategoryModels: [ShowCategoryModel] = [
    ShowCategoryModel(name: NSLocalizedString("categoryRecommended", comment: ""), showsID: ["53647", "41074", "60", "38963", "30", "31683"]),
    ShowCategoryModel(name: NSLocalizedString("categoryPopular", comment: ""), showsID: ["169", "7103", "38963", "53647"]),
    ShowCategoryModel(name: NSLocalizedString("categoryHorror", comment: ""), showsID: ["53647", "1791", "30", "31683"]),
    ShowCategoryModel(name: NSLocalizedString("categoryCrime", comment: ""), showsID: ["60", "32158", "21532"]),
    ShowCategoryModel(name: NSLocalizedString("categoryDocumentary", comment: ""), showsID: ["41074", "33952", "13644", "7103"])
]

