//
//  PlayerConfiguration.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 17/03/23.
//

import Foundation

struct PlayerConfiguration {
    let range: CGFloat = 5
    let attackSpeed: CGFloat = 0.5
    let movementSpeed: Int = 1
    let jumpValue: CGFloat = 1
    let runTimePerFrame: TimeInterval = 0.03
    let hitTimePerFrame: TimeInterval = 0.05
    let runRightAnimation = "Dice Run Right"
    let runLeftAnimation = "Dice Run Left"
    let hitAnimation = "Dice Hit"
}
