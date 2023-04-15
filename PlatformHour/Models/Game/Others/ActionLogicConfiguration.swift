//
//  ActionLogicConfiguration.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 14/04/23.
//

import Foundation

struct ActionLogicConfiguration {
    init(timer: Timer? = nil,
                direction: ActionLogicConfiguration.Direction = .none,
                movementSpeed: Int = 0,
                isLongPressingDPad: Bool = false) {
        self.timer = timer
        self.direction = direction
        self.movementSpeed = movementSpeed
        self.isLongPressingDPad = isLongPressingDPad
    }
    
    
    enum Direction: String, CaseIterable {
        case none
        case up
        case down
        case right
        case left
    }
    
    var timer: Timer?
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
