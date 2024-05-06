//
//  ImageModel.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 05.04.2024.
//

import Foundation

struct ImageModel: Codable
{
    var id:Int
    var type:String
    var main:Bool
    var resolutions:Resolutions
    
    struct Resolutions: Codable {
        var original:OriginalAndMedium
        var medium:OriginalAndMedium?
        
        struct OriginalAndMedium:Codable {
            var url:String
            var width:Int
            var height:Int
        }
    }
}
