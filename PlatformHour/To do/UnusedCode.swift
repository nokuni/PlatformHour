//
//  UnusedCode.swift
//  PlatformHour
//
//  Created by Yann Christophe MAERTENS on 17/04/2023.
//

import Foundation

// MARK: - Unused Code

//    public func updatePlatformCoordinates() {
//        guard let environment = scene.core?.environment else { return }
//        let platform = environment.map.objects.first { $0.name == "Platform" }
//        guard let platform = platform else { return }
//
//        let element = environment.allElements.first {
//            $0.contains(platform.position)
//        }
//
//        if let tileElement = element as? PKTileNode {
//            platform.coordinate = tileElement.coordinate
//        }
//
//        if let objectElement = element as? PKObjectNode {
//            platform.coordinate = objectElement.coordinate
//        }
//    }

//private func dropDestroyCube(coordinate: Coordinate) {
//    guard let player = scene.player else { return }
//    if let cube = environment.map.objects.first(where: {
//        guard let name = $0.name else { return false }
//        let isCube = name.contains("Cube")
//        let isRightCube = name.extractedNumber == player.currentRoll.rawValue
//        let isRightCoordinate = $0.coordinate == coordinate
//        return isCube && isRightCube && isRightCoordinate
//    }) {
//        instantDestroy(cube)
//    }
//}

//    public func updatePlayerHealth() {
//        guard let dice = scene.player else { return }
//        guard let healthBar = dice.node.childNode(withName: "Health Bar") else { return }
//        healthBar.removeFromParent()
//        scene.core?.content?.addHealthBar(amount: dice.currentBarHealth,
//                                          node: dice.node,
//                                          widthTailoring: (GameConfiguration.worldConfiguration.tileSize.width / 16) * 4)
//    }

/// Adds a health bar to the player.
/*func addHealthBar(amount: CGFloat,
 node: PKObjectNode,
 widthTailoring: CGFloat = 0) {
 let tileSize = GameConfiguration.worldConfiguration.tileSize

 let bar = SKSpriteNode(imageNamed: "healthBar")
 bar.size = CGSize(width: tileSize.width - widthTailoring, height: tileSize.height)
 bar.texture?.filteringMode = .nearest

 let underBar = SKSpriteNode(imageNamed: "emptyBar")
 underBar.size = CGSize(width: tileSize.width - widthTailoring, height: tileSize.height)
 underBar.texture?.filteringMode = .nearest

 let configuration = PKProgressBarNode.ImageConfiguration(amount: amount,
 sprite: bar,
 underSprite: underBar)
 let progressBar = PKProgressBarNode(imageConfiguration: configuration)
 progressBar.name = "Health Bar"
 progressBar.position = CGPoint(x: 0, y: node.frame.size.height / 2)

 node.addChildSafely(progressBar)
 }*/

/// Add an orb split effect at a position on the scene.
/*func orbSplitEffect(scene: GameScene, on position: CGPoint) {
 let tileSize = GameConfiguration.sceneConfiguration.tileSize
 let positions = [
 CGPoint(x: position.x, y: position.y + tileSize.height),
 CGPoint(x: position.x + tileSize.width, y: position.y + tileSize.height),
 CGPoint(x: position.x + tileSize.width, y: position.y),
 CGPoint(x: position.x + tileSize.width, y: position.y - tileSize.height),
 CGPoint(x: position.x, y: position.y - tileSize.height),
 CGPoint(x: position.x - tileSize.width, y: position.y - tileSize.height),
 CGPoint(x: position.x - tileSize.width, y: position.y),
 CGPoint(x: position.x - tileSize.width, y: position.y + tileSize.height),
 ]
 for pos in positions {
 let orb = SKSpriteNode(imageNamed: "orb0")
 orb.size = tileSize
 orb.texture?.filteringMode = .nearest
 orb.zPosition = GameConfiguration.sceneConfiguration.hudZPosition
 orb.position = position
 scene.addChildSafely(orb)

 let scale = SKAction.scaleUpAndDown(from: 0.1,
 with: 0.05,
 to: 1,
 with: 0.05,
 during: 0,
 repeating: 10)
 let fade = SKAction.fadeOut(withDuration: 0.5)
 let move = SKAction.move(to: pos, duration: 0.5)
 let groupAnimation = SKAction.group([scale, fade, move])

 let sequenceAnimation = SKAction.sequence([
 groupAnimation,
 SKAction.removeFromParent()
 ])

 orb.run(sequenceAnimation)
 }
 }*/

/*
 {
 "id": 0,
 "name": "Blue Gem A",
 "category": "collectible",
 "coordinate": "2917"
 },
 */

/*
 //        guard let player = scene.player else { return }
 //        guard let environment = scene.core?.environment else { return }
 //        player.hitted(scene: scene, by: enemyNode) {
 //            if let playerCoordinate = self.scene.player?.node.coordinate {
 //                let groundCoordinate = Coordinate(x: playerCoordinate.x + 1, y: playerCoordinate.y)
 //                if !environment.isCollidingWithObject(at: groundCoordinate) {
 //                    self.scene.core?.logic?.dropPlayer()
 //                }
 //                self.scene.core?.logic?.endSequenceAction()
 //                self.scene.core?.logic?.damagePlayer(with: enemyNode)
 //                self.scene.player?.state = .normal
 //                self.scene.core?.logic?.enableControls()
 //            }
 //        }
 */
