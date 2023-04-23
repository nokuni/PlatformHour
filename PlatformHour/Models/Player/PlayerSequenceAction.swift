//
//  PlayerSequenceAction.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 24/04/23.
//

import Foundation

enum PlayerSequenceAction {
    case none
    case moveRight
    case moveLeft
    case moveUp
    case moveDown
    
    var icon: String {
        switch self {
        case .none:
            return ""
        case .moveRight:
            return GameConfiguration.imageKey.rightArrow
        case .moveLeft:
            return GameConfiguration.imageKey.leftArrow
        case .moveUp:
            return GameConfiguration.imageKey.upArrow
        case .moveDown:
            return GameConfiguration.imageKey.downArrow
        }
    }
    
    var value: (x: Int, y: Int) {
        switch self {
        case .none:
            return (x: 0, y: 0)
        case .moveRight:
            return (x: 0, y: 1)
        case .moveLeft:
            return (x: 0, y: -1)
        case .moveUp:
            return (x: -1, y: 0)
        case .moveDown:
            return (x: 1, y: 0)
        }
    }
}
