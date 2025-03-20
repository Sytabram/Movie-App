//
//  ShowCategoryModel.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 02.04.2024.
//

import Foundation

struct ShowCategoryModel
{
    var name: String
    var showsID: [String]
}

let mockShowCategoryModels: [ShowCategoryModel] = [
    ShowCategoryModel(name: "Recommended", showsID: ["53647", "41074", "60", "38963", "30", "31683"]),
    ShowCategoryModel(name: "Popular", showsID: ["169", "7103", "38963", "53647"]),
    ShowCategoryModel(name: "Horror", showsID: ["53647", "1791", "30", "31683"]),
    ShowCategoryModel(name: "Crime", showsID: ["60", "32158", "21532"]),
    ShowCategoryModel(name: "Documentary", showsID: ["41074", "33952", "13644", "7103"])
]

