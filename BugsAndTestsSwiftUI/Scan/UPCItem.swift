//
//  UPCItem.swift
//  BugsAndTestsSwiftUI
//
//  Created by Admin on 12/05/2021.
//

import Foundation


let json = """
    {
      "code": "OK",
      "total": 1,
      "offset": 0,
      "items": [
        {
          "ean": "7045950671798",
          "title": "Swix F4 Liquid Ski Wax 80 ML Item",
          "description": "",
          "asin": "B000XP87AW",
          "brand": "Swix",
          "model": "F4 Premium",
          "color": "",
          "size": "",
          "dimension": "",
          "weight": "",
          "category": "Sporting Goods > Outdoor Recreation > Winter Sports & Activities > Skiing & Snowboarding > Ski & Snowboard Wax",
          "lowest_recorded_price": 15,
          "highest_recorded_price": 65.34,
          "images": [],
          "offers": [],
          "elid": "162623294623"
        }
      ]
    }
    """
struct UPCItemRequest: Decodable {
    var items: [UPCItem]
    var item: UPCItem? {
        items.first
    }
}

struct UPCItem: Decodable {   
    var ean: String
    var title: String
    var description: String
    var brand: String
    var model: String
}


