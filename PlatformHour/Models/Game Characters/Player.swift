//
//  Player.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 01/02/23.
//

import SpriteKit
import PlayfulKit

public class Player {
    
    public var orientation: Orientation = .right
    public var node: PKObjectNode = PKObjectNode()
    
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
    }
    public enum SequenceAction {
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
                return GameConfiguration.imageConfigurationKey.rightArrow
            case .moveLeft:
                return GameConfiguration.imageConfigurationKey.leftArrow
            case .moveUp:
                return GameConfiguration.imageConfigurationKey.upArrow
            case .moveDown:
                return GameConfiguration.imageConfigurationKey.downArrow
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
    public enum ControllerState {
        case normal
        case inAction
        case inDialog
    }
    
    public struct Stats {
        public init(range: CGFloat, attackSpeed: CGFloat) {
            self.range = range
            self.attackSpeed = attackSpeed
        }
        
        public var range: CGFloat
        public var attackSpeed: CGFloat
    }
    
    public var controllerState: ControllerState = .normal
    public var currentRoll: Roll = .one
    public var stats = Stats(range: GameConfiguration.playerConfiguration.range,
                             attackSpeed: GameConfiguration.playerConfiguration.attackSpeed)
    public var logic: GameObjectLogic = GameObjectLogic(health: 1,
                                                        damage: 1,
                                                        isDestructible: true,
                                                        isIntangible: false)
    
    public var state: PlayerState = PlayerState()
    
    public var interactionStatus: PlayerInteractionStatus = .none
    public var actions: [SequenceAction] = []
    
    public var bag: [GameItem] = []
}

extension Player {
    
    func frames(id: String) -> [String]? {
        let currentRollValue = currentRoll.rawValue
        let animation = GameSpriteAnimation.get(id)
        let frames = animation?.frames.compactMap {
            $0.replacingOccurrences(of: "#", with: "\(currentRollValue)")
        }
        return frames
    }
    
    var runDuration: Double {
        let rightRunFrames = frames(id: GameConfiguration.playerConfiguration.runRightAnimation)
        guard let framesCount = rightRunFrames?.count else { return 0 }
        let duration = Double(framesCount) * GameConfiguration.playerConfiguration.runTimePerFrame
        return duration
    }
    
    var currentHealth: Int {
        logic.health - node.logic.healthLost
    }
    
    var currentBarHealth: CGFloat {
        CGFloat(currentHealth) / CGFloat(logic.health)
    }
    
    // MARK: - Actions
    private func knockedBack(by enemy: PKObjectNode) -> SKAction {
        let tileSize = GameConfiguration.worldConfiguration.tileSize
        let knockBack = enemy.xScale > 0 ?
        SKAction.move(to: CGPoint(x: node.position.x + (tileSize.width * 2), y: node.position.y), duration: 0.1) :
        SKAction.move(to: CGPoint(x: node.position.x - (tileSize.width * 2), y: node.position.y), duration: 0.1)
        return knockBack
    }
    
    // MARK: - Animations
    func run() {
        guard let rightRunFrames = frames(id: GameConfiguration.playerConfiguration.runRightAnimation) else { return }
        guard let leftRunFrames = frames(id: GameConfiguration.playerConfiguration.runLeftAnimation) else { return }
        let frames = orientation == .right ? rightRunFrames : leftRunFrames
        let action = SKAction.animate(with: frames, filteringMode: .nearest, timePerFrame: GameConfiguration.playerConfiguration.runTimePerFrame)
        SKAction.start(actionOnLaunch: nil, animation: action, node: node, actionOnEnd: nil)
    }
    
    func death(scene: GameScene) {
        guard let deathFrames = frames(id: GameConfiguration.playerConfiguration.deathAnimation) else { return }
        let animationNode = SKSpriteNode()
        animationNode.size = GameConfiguration.worldConfiguration.tileSize
        animationNode.position = node.position
        scene.addChild(animationNode)
        
        let animation = SKAction.animate(with: deathFrames, filteringMode: .nearest, timePerFrame: GameConfiguration.playerConfiguration.deathTimePerFrame)
        
        let sequence = SKAction.sequence([
            animation,
            SKAction.fadeOutAndIn(fadeOutDuration: 0.05, fadeInDuration: 0.05, repeating: 5),
            SKAction.removeFromParent()
        ])
        
        SKAction.start(actionOnLaunch: node.removeFromParent,
                       animation: sequence,
                       node: animationNode,
                       actionOnEnd: nil)
    }
    
    func hitted(scene: GameScene, by enemy: PKObjectNode, completion: (() -> Void)?) {
        guard let hitFrames = frames(id: GameConfiguration.playerConfiguration.hitAnimation) else { return }
        let hitAnimation = SKAction.animate(with: hitFrames, filteringMode: .nearest, timePerFrame: GameConfiguration.playerConfiguration.hitTimePerFrame)
        let knockBackAnimation = knockedBack(by: enemy)
        let groupedAnimation = SKAction.group([hitAnimation, knockBackAnimation])
        node.removeAllActions()
        SKAction.start(actionOnLaunch: nil, animation: groupedAnimation, node: node) {
            completion?()
        }
    }
    
    // MARK: - Logic
    func advanceRoll() {
        guard let lastRoll = Roll.allCases.last?.rawValue else { return }
        if currentRoll.rawValue < lastRoll {
            currentRoll.next()
        } else {
            currentRoll = .one
        }
    }
    func resetToOne() {
        currentRoll = .one
        node.texture = SKTexture(imageNamed: "player1Idle")
        node.texture?.filteringMode = .nearest
    }
}
