//
//  ActionLogicConfiguration.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 14/04/23.
//

import Foundation

public struct ActionLogicConfiguration {
    public init(timer: Timer? = nil,
                direction: ActionLogicConfiguration.Direction = .none,
                movementSpeed: Int = 0,
                isLongPressingDPad: Bool = false) {
        self.timer = timer
        self.direction = direction
        self.movementSpeed = movementSpeed
        self.isLongPressingDPad = isLongPressingDPad
    }
    
    
    public enum Direction: String, CaseIterable {
        case none
        case up
        case down
        case right
        case left
    }
    
    public var timer: Timer?
    public var direction: Direction = .none
    public var movementSpeed: Int = 0
    public var isLongPressingDPad: Bool = false
    
    public func isAttacking(scene: GameScene) -> Bool {
        scene.isExistingChildNode(named: GameConfiguration.nodeKey.playerProjectile)
    }
}
