//
//  ShowCategoryModel.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 02.04.2024.
//

import Foundation

struct ShowCategoryModel
{
    var categoryShowsID: [(String, [String])] = []
    
    init() {
        // Add show by category for the home screen
        categoryShowsID.append(("Recommended", ["53647", "41074", "60", "38963", "30", "31683"]))
        categoryShowsID.append(("Popular", ["169", "7103", "38963", "53647"]))
        categoryShowsID.append(("Horror", ["53647", "1791", "30", "31683"]))
        categoryShowsID.append(("Crime", ["60", "32158", "21532"]))
        categoryShowsID.append(("Documentary", ["41074", "33952", "13644", "7103"]))
        }
}
