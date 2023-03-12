//
//  GameLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 05/02/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

final public class GameLogic {
    
    public init(scene: GameScene,
                dimension: GameDimension,
                animation: GameAnimation,
                environment: GameEnvironment) {
        self.scene = scene
        self.dimension = dimension
        self.animation = animation
        self.environment = environment
    }
    
    public var scene: GameScene
    public var dimension: GameDimension
    public var animation: GameAnimation
    public var environment: GameEnvironment
    
    public func damageObject(_ objectNode: PKObjectNode, with projectileNode: PKObjectNode) {
        guard objectNode.logic.isDestructible else { return }
        objectNode.logic.healthLost += projectileNode.logic.damage
        damage(objectNode)
    }
    
    private func isDestroyed(_ objectNode: PKObjectNode) -> Bool {
        objectNode.logic.healthLost >= objectNode.logic.health
    }
    
    private func destroy(_ objectNode: PKObjectNode) {
        if isDestroyed(objectNode) {
            objectNode.physicsBody?.categoryBitMask = .zero
            objectNode.physicsBody?.contactTestBitMask = .zero
            objectNode.physicsBody?.collisionBitMask = .zero
            animation.destroy(node: objectNode,
                              filteringMode: .nearest) {
                self.environment.createSphere(at: objectNode.coordinate)
            }
        }
    }
    
    private func hit(_ objectNode: PKObjectNode) {
        animation.hit(node: objectNode,
                      filteringMode: .nearest)
    }
    
    private func damage(_ objectNode: PKObjectNode) {
        hit(objectNode)
        destroy(objectNode)
    }
    
    private func updateSphereRequirement() {
        guard let portalNode = environment.map.childNode(withName: "Portal") as? PKObjectNode else { return }
        guard let portalRequirementNode = portalNode.childNode(withName: "Portal Requirement") else { return }
        portalRequirementNode.removeAllChildren()
        environment.levelRequirement.intoSprites(with: "indicator",
                                                 filteringMode: .nearest,
                                                 spacing: 0.5,
                                                 of: CGSize(width: 50, height: 50),
                                                 at: CGPoint(x: 0, y: dimension.tileSize.height),
                                                 on: portalRequirementNode)
        if environment.isExitOpen {
            portalRequirementNode.removeFromParent()
            let action = portalNode.animatedAction(with: "open", filteringMode: .nearest, timeInterval: 0.1, isRepeatingForever: true)
            portalNode.run(action)
        }
    }
    
    public func moveSpherePart(to objectNode: PKObjectNode) {
//        if let exitCoordinate = scene.game?.exitCoordinate,
//           let exitPosition = environment.map.tilePosition(from: exitCoordinate) {
//            let sequence = SKAction.sequence([
//                objectNode.animatedAction(with: "idle", filteringMode: .nearest, timeInterval: 0.1),
//                SKAction.move(from: objectNode.position, to: exitPosition, at: 500),
//                SKAction.removeFromParent(),
//                SKAction.run { self.updateSphereRequirement() }
//            ])
//            
//            objectNode.run(sequence)
//        }
    }
}
