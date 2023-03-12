//
//  Player.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 01/02/23.
//

import SpriteKit
import PlayfulKit

public struct Player: Identifiable {
    internal init(id: UUID = UUID(),
                  sprite: String = "playerIdle",
                  orientation: Player.Orientation = .right,
                  node: PKObjectNode = PKObjectNode(),
                  currentRoll: Player.Roll = .one,
                  range: CGFloat = 5,
                  attackSpeed: CGFloat = 0.5) {
        self.id = id
        self.sprite = sprite
        self.orientation = orientation
        self.node = node
        self.currentRoll = currentRoll
        self.range = range
        self.attackSpeed = attackSpeed
    }
    
    public var id: UUID
    public var sprite: String
    public var orientation: Orientation
    public var node: PKObjectNode
    
    public enum Roll: Int, CaseIterable {
        case one = 1
        case two = 2
        case three = 3
        case four = 4
        case five = 5
        case six = 6
    }
    public enum Orientation {
        case right
        case left
        case up
        case down
        
        var arrow: String {
            switch self {
            case .right:
                return "arrowRight"
            case .left:
                return "arrowLeft"
            case .up:
                return "arrowUp"
            case .down:
                return "arrowDown"
            }
        }
    }
    
    public var currentRoll: Roll
    public var range: CGFloat
    public var attackSpeed: CGFloat
    
    public var bag: [GameItem] = []
}

extension Player {
    
    func run() {
        let run = try! Sprite.get("playerRun", state: .run)
        let idle = try! Sprite.get("playerIdle", state: .idle)
        
        let runFrame = run.name + "\(currentRoll.rawValue - 1)"
        let idleFrame = idle.name + "\(currentRoll == .six ? 0 : currentRoll.rawValue)"
        let frames = [runFrame, idleFrame]
        
        let action = SKAction.animate(with: frames, filteringMode: .nearest, timePerFrame: 0.1)
        
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
