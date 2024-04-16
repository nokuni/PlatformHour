//
//  StructurePattern.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 06/04/23.
//

import Foundation
import UtilityToolbox

struct StructurePattern: Codable {
    
    public init(name: String, corners: [String], borders: [String]) {
        self.name = name
        self.corners = corners
        self.borders = borders
    }
    
    var name: String
    var corners: [String]
    var borders: [String]
}

extension StructurePattern {
    
    static var all: [StructurePattern]? {
        try? GameConfiguration.bundleManager.decodeJSON(GameConfiguration.jsonKey.structures)
    }
    
    static func get(_ name: String) -> StructurePattern? {
        let pattern = StructurePattern.all?.first(where: { $0.name == name })
        return pattern
    }
}
