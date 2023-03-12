//
//  GameObjectContainer.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 12/03/23.
//

import Foundation

struct GameObjectContainer: Codable {
    let name: String
    let coordinate: Int
    var item: String? = nil
}
