//
//  LevelCinematic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 09/04/23.
//

import Foundation

public struct LevelCinematic: Codable {
    public init(name: String,
                triggerCoordinate: String,
                category: Category,
                isAvailable: Bool = true) {
        self.name = name
        self.triggerCoordinate = triggerCoordinate
        self.category = category
        self.isAvailable = isAvailable
    }
    
    public let name: String
    public let triggerCoordinate: String?
    public let category: Category
    public var isAvailable: Bool = true
    
    public enum Category: String, Codable {
        case onStart
        case onDialog
    }
    
    enum CodingKeys: String, CodingKey {
        case name
        case triggerCoordinate
        case category
    }
}
