//
//  PlayerState.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 06/04/23.
//

import Foundation

struct PlayerState {
    init(hasProjectileTurningBack: Bool = false,
                isJumping: Bool = false,
                isDead: Bool = false) {
        self.hasProjectileTurningBack = hasProjectileTurningBack
        self.isJumping = isJumping
        self.isDead = isDead
    }
    
    var hasProjectileTurningBack: Bool
    var isJumping: Bool
    var isDead: Bool
}
