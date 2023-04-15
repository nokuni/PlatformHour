//
//  LevelStructure.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 26/03/23.
//

import Foundation

struct LevelStructure: Codable {
    init(atlasName: String,
                outline: String,
                firstLayer: String? = nil,
                innerLayer: String? = nil,
                innerLayerAmount: Int? = nil,
                matrix: String, coordinate: String) {
        self.atlasName = atlasName
        self.outline = outline
        self.firstLayer = firstLayer
        self.innerLayer = innerLayer
        self.innerLayerAmount = innerLayerAmount
        self.matrix = matrix
        self.coordinate = coordinate
    }
    
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
