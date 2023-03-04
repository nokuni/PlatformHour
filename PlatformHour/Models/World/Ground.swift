//
//  GameGround.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 10/02/23.
//

import Foundation
import PlayfulKit

extension MapStructure {
    
    enum MapStructureError: String, Error {
        case noStructureFound
    }
    
    static var all: [MapStructure] { try! Bundle.main.decodeJSON("structures.json") }
    
    static func get(_ name: String) throws -> MapStructure {
        let structure = MapStructure.all.first(where: { $0.name == name })
        if let structure = structure { return structure }
        throw MapStructureError.noStructureFound.rawValue
    }
}
