//
//  ShowModel.swift
//  Movie App
//
//  Created by Bryan Zweiacker on 01.04.2024.
//

import Foundation



struct ShowModel: Codable
{
    var id:Int
    var url:String?
    var name:String?
    var type:String?
    var language:String?
    var genres:[String]?
    var status:String?
    var runtime:Int?
    var averageRuntime:Int?
    var premiered:String?
    var ended:String?
    var officialSite:String?
    var schedule:Schedule?
    var rating:Rating?
    var weight:Int?
    var network:Network?
    var webChannel:WebChannel?
    var dvdCountry:Double?
    var externals:Externals?
    var image:Image?
    var summary:String?
    var updated:Int?
    var _links:Links?
    
    struct Schedule: Codable {
        var time:String?
        var days:[String]?
    }
    struct Rating: Codable {
        var average:Double?
    }
    struct Network: Codable {
        var id:Int?
        var name:String?
        var country:country?
        var officialSite:String?
        
        struct country: Codable {
            var name:String?
            var code:String?
            var timezone:String?
        }
    }
    struct WebChannel:Codable {
        var id:Int?
        var name:String?
        var country:Country?
        var officialSite:String?
        
        struct Country:Codable{
            var name: String?
            var code:String?
            var timezone:String?
        }
    }
    struct Externals:Codable{
        var tvrage: Int?
        var thetvdb:Int?
        var imdb:String?
    }
    struct Image:Codable {
        var medium:String?
        var original:String?
    }
    
    struct Links:Codable {
        var `self`:SelfLinks?
        var previousepisode:PreviousEpisode?
        
        struct SelfLinks:Codable {
            var href:String?
        }
        struct PreviousEpisode:Codable {
            var href:String?
            var name:String?
        }
    }
    
    
}

