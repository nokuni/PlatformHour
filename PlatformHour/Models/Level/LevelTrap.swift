//
//  LevelTrap.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/04/23.
//

import Foundation

public struct LevelTrap: Codable {
    public init(id: String, name: String, coordinate: String) {
        self.id = id
        self.name = name
        self.coordinate = coordinate
    }
    
    public let id: String
    public let name: String
    public let coordinate: String
}
