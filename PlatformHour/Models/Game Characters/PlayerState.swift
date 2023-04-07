//
//  PlayerState.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 06/04/23.
//

import Foundation

public struct PlayerState {
    public init(hasProjectileTurningBack: Bool = false,
                isJumping: Bool = false,
                canAct: Bool = true,
                isDead: Bool = false) {
        self.hasProjectileTurningBack = hasProjectileTurningBack
        self.isJumping = isJumping
        self.canAct = canAct
        self.isDead = isDead
    }
    
    public var hasProjectileTurningBack: Bool
    public var isJumping: Bool
    public var canAct: Bool
    public var isDead: Bool
}
