//
//  LevelStructure.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 26/03/23.
//

import Foundation

public struct LevelStructure: Codable {
    public init(outline: String,
                firstLayer: String? = nil,
                innerLayer: String? = nil,
                innerLayerAmount: Int? = nil,
                matrix: String, coordinate: String) {
        self.outline = outline
        self.firstLayer = firstLayer
        self.innerLayer = innerLayer
        self.innerLayerAmount = innerLayerAmount
        self.matrix = matrix
        self.coordinate = coordinate
    }
    
    public let outline: String
    public let firstLayer: String?
    public let innerLayer: String?
    public let innerLayerAmount: Int?
    public let matrix: String
    public let coordinate: String
    
    enum CodingKeys: String, CodingKey {
        case outline
        case firstLayer
        case innerLayer
        case innerLayerAmount
        case matrix
        case coordinate
    }
}
