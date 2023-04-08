//
//  StructurePattern.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 06/04/23.
//

import Foundation

struct StructurePattern: Codable {
    var name: String
    var corners: [String]
    var borders: [String]
}

extension StructurePattern {
    static var all: [StructurePattern]? {
        try? Bundle.main.decodeJSON(GameConfiguration.jsonKey.structures)
    }
    
    static func get(_ name: String) -> StructurePattern? {
        let pattern = StructurePattern.all?.first(where: { $0.name == name })
        return pattern
    }
}
