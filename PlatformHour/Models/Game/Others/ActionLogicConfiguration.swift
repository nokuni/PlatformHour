//
//  ActionLogicConfiguration.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 14/04/23.
//

import Foundation

struct ActionLogicConfiguration {
    
    enum Direction: String, CaseIterable {
        case none
        case up
        case down
        case right
        case left
    }
    
    var timer: Timer? = nil
    var direction: Direction = .none
    var movementSpeed: Int = 0
    var isLongPressingDPad: Bool = false
    
    func isAttacking(scene: GameScene) -> Bool {
        scene.isExistingChildNode(named: GameConfiguration.nodeKey.playerProjectile)
    }
    
    func isEnabled(scene: GameScene) -> Bool {
        scene.game?.controller?.manager?.action != nil
    }
}
