//
//  LevelStructure.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 26/03/23.
//

import Foundation

struct LevelStructure: Codable {
    let atlasName: String
    let outline: String
    let firstLayer: String?
    let innerLayer: String?
    let innerLayerAmount: Int?
    let matrix: String
    let coordinate: String
    
    enum CodingKeys: String, CodingKey {
        case atlasName
        case outline
        case firstLayer
        case innerLayer
        case innerLayerAmount
        case matrix
        case coordinate
    }
}
