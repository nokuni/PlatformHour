//
//  Game.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 10/02/23.
//

import SwiftUI
import PlayfulKit

class Game: ObservableObject {
    
    init() {
        world = try? GameWorld.get(currentWorld)
        level = try? GameLevel.get(currentLevel)
    }
    
    @AppStorage("world") var currentWorld = "Timeless Temple"
    @AppStorage("level") var currentLevel = 0
    var controller: GameControllerManager?
    
    var world: GameWorld?
    var level: GameLevel?
    
    let playerCoordinate: Coordinate = Coordinate(x: 13, y: 10)
    let entrancePortalCoordinate: Coordinate = Coordinate(x: 13, y: 7)
    let exitPortalCoordinate: Coordinate = Coordinate(x: 13, y: 40)
}
