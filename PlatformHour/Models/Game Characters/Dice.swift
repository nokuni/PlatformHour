//
//  Dice.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 01/02/23.
//

import SpriteKit
import PlayfulKit

struct Player {
    var sprite: String = "playerIdle"
    var node = SKSpriteNode()
    
    enum Roll: Int, CaseIterable {
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
    }
    
    var currentRoll: Roll = .one
    
    func run() {
        let animation = PKAnimation()
        
        let run = try! Sprite.get("playerRun", state: .run)
        let idle = try! Sprite.get("playerIdle", state: .idle)
        
        let runFrame = run.name + "\(currentRoll.rawValue - 1)"
        let idleFrame = idle.name + "\(currentRoll == .six ? 0 : currentRoll.rawValue)"
        let frames = [runFrame, idleFrame]
        
        let action = animation.spriteAnimation(images: frames, filteringMode: .nearest, timePerFrame: 0.1)
        
        node.run(action)
    }
    
    func stop() {
        node.texture = SKTexture(imageNamed: "playerIdle\(currentRoll.rawValue - 1)")
        node.texture?.filteringMode = .nearest
    }
    
    mutating func advanceRoll() {
        if currentRoll.rawValue < 6 {
            currentRoll.next()
        } else {
            currentRoll = .one
        }
    }
}
