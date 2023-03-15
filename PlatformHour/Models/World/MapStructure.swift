//
//  MapStructure.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 10/02/23.
//

import Foundation
import PlayfulKit

extension MapStructure {
    
    static var all: [MapStructure]? {
        try? Bundle.main.decodeJSON(GameApp.jsonConfigurationKey.structures)
    }
    
    static func get(_ name: String) throws -> MapStructure? {
        let structure = MapStructure.all?.first(where: {
            $0.name == name
        })
        return structure
    }
}
