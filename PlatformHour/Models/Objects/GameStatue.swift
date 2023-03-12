//
//  GameStatue.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 12/03/23.
//

import Foundation

struct GameStatue: Codable {
    let sprites: [String]
    let coordinates: [Int]
    var requirement: [String]
}
