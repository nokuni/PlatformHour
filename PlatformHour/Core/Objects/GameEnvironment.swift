//
//  GameEnvironment.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SwiftUI
import SpriteKit
import PlayfulKit
import Utility_Toolbox

extension String.StringInterpolation {
    mutating func appendImageInterpolation(_ value: String) {
        appendInterpolation("My name is \(value) and I'm \(value)")
    }
}

final public class GameEnvironment {
    
    public init(scene: GameScene,
                dimension: GameDimension,
                animation: GameAnimation) {
        self.scene = scene
        self.dimension = dimension
        self.animation = animation
        createEnvironment()
    }
    
    public var scene: GameScene
    public var dimension: GameDimension
    public var animation: GameAnimation
    public var map = PKMapNode()
    
    private let mapMatrix = Matrix(row: 18, column: 50)
    
    /// Coordinates of all objects in the map.
    public var coordinates: [Coordinate] {
        let objects = map.objects.filter { !$0.logic.isIntangible }
        let coordinates = objects.map { $0.coordinate }
        return coordinates
    }
    
    public var levelRequirement: Int {
        let vases = map.objects.filter { $0.name == "Vase" }
        return vases.count
    }
    
    public var isExitOpen: Bool {
        levelRequirement == 0
    }
    
    // MARK: - Objects
    public func object(name: String? = nil,
                       physicsBodySizeTailoring: CGFloat = 0,
                       collision: Collision) -> PKObjectNode {
        
        let object = PKObjectNode()
        object.name = name
        object.size = dimension.tileSize
        
        object.applyPhysicsBody(
            size: object.size + physicsBodySizeTailoring,
            collision: collision
        )
        
        return object
    }
    public var structureElement: PKObjectNode {
        let collision = Collision(category: .structure,
                                  collision: [.player, .object, .playerProjectile, .enemyProjectile],
                                  contact: [.player, .object, .playerProjectile, .enemyProjectile])
        let structureElement = object(collision: collision)
        structureElement.physicsBody?.friction = 0
        structureElement.physicsBody?.isDynamic = false
        structureElement.physicsBody?.affectedByGravity = false
        structureElement.physicsBody?.usesPreciseCollisionDetection = true
        return structureElement
    }
    public func backgroundElement(name: String? = nil, collision: Collision) -> PKObjectNode {
        let structureElement = object(collision: collision)
        structureElement.name = name
        structureElement.physicsBody?.isDynamic = false
        structureElement.physicsBody?.affectedByGravity = false
        return structureElement
    }
    
    // MARK: - Creations
    private func createEnvironment() {
        createMap()
        createSky()
        createGround()
        createTrees()
        createStatue()
        createContainers()
    }
    
    private func createMap() {
        map = PKMapNode(squareSize: dimension.tileSize,
                        matrix: mapMatrix)
        scene.addChild(map)
    }
    private func createSky() {
        if let world = scene.game?.world {
            let matrix = Matrix(row: mapMatrix.row - 4, column: mapMatrix.column)
            map.drawTexture(world.skyName,
                            filteringMode: .nearest,
                            matrix: matrix,
                            startingCoordinate: Coordinate.zero)
        }
    }
    
    private func createGround() {
        let coordinate = Coordinate(x: 14, y: 0)
        
        if let world = scene.game?.world {
            let structure: MapStructure = MapStructure(topLeft: world.ground.topLeft,
                                                       topRight: world.ground.topRight,
                                                       bottomLeft: world.ground.bottomLeft,
                                                       bottomRight: world.ground.bottomRight,
                                                       left: world.ground.left,
                                                       right: world.ground.right,
                                                       top: world.ground.top,
                                                       bottom: world.ground.bottom,
                                                       middle: world.ground.middle)
            map.addObject(structureElement,
                          structure: structure,
                          filteringMode: .nearest,
                          logic: LogicBody(),
                          animations: [],
                          startingCoordinate: coordinate,
                          matrix: Matrix(row: 4, column: mapMatrix.column))
        }
    }
    
    private func createStatue() {
        
        guard let statue = scene.game?.level?.statue else { return }
        
        let collision = Collision(category: .object,
                                  collision: [.allClear],
                                  contact: [.player])
        
        map.addObject(backgroundElement(name: "Statue", collision: collision),
                      image: "springStatueTopLeft",
                      filteringMode: .nearest,
                      logic: LogicBody(isIntangible: true),
                      animations: [],
                      at: statue.coordinates[0].coordinate)
        
        map.addObject(backgroundElement(name: "Statue", collision: collision),
                      image: "springStatueTopRight",
                      filteringMode: .nearest,
                      logic: LogicBody(isIntangible: true),
                      animations: [],
                      at: statue.coordinates[1].coordinate)
        
        map.addObject(backgroundElement(name: "Statue", collision: collision),
                      image: "springStatueBottomLeft",
                      filteringMode: .nearest,
                      logic: LogicBody(isIntangible: true),
                      animations: [],
                      at: statue.coordinates[2].coordinate)
        
        map.addObject(backgroundElement(name: "Statue", collision: collision),
                      image: "springStatueBottomRight",
                      filteringMode: .nearest,
                      logic: LogicBody(isIntangible: true),
                      animations: [],
                      at: statue.coordinates[3].coordinate)
    }
    private func createTrees() {
        
        let collision = Collision(category: .allClear,
                                  collision: [.allClear],
                                  contact: [.allClear])
        
        var startingCoordinate = Coordinate(x: 13, y: 0)
        
        for _ in 0..<6 {
            map.addObject(backgroundElement(collision: collision),
                          image: "springTreeTopLeft",
                          filteringMode: .nearest,
                          logic: LogicBody(isIntangible: true),
                          animations: [],
                          at: .init(x: startingCoordinate.x - 1, y: startingCoordinate.y + 1))
            
            map.addObject(backgroundElement(collision: collision),
                          image: "springTreeTopRight",
                          filteringMode: .nearest,
                          logic: LogicBody(isIntangible: true),
                          animations: [],
                          at: .init(x: startingCoordinate.x - 1, y: startingCoordinate.y + 2))
            
            map.addObject(backgroundElement(collision: collision),
                          image: "springTreeBottomRight",
                          filteringMode: .nearest,
                          logic: LogicBody(isIntangible: true),
                          animations: [],
                          at: .init(x: startingCoordinate.x, y: startingCoordinate.y + 1))
            
            map.addObject(backgroundElement(collision: collision),
                          image: "springTreeBottomLeft",
                          filteringMode: .nearest,
                          logic: LogicBody(isIntangible: true),
                          animations: [],
                          at: .init(x: startingCoordinate.x, y: startingCoordinate.y + 2))
            
            map.addObject(backgroundElement(collision: collision),
                          image: "springTreeTopLeft",
                          filteringMode: .nearest,
                          logic: LogicBody(isIntangible: true),
                          animations: [],
                          at: .init(x: startingCoordinate.x, y: startingCoordinate.y))
            
            map.addObject(backgroundElement(collision: collision),
                          image: "springTreeTopRight",
                          filteringMode: .nearest,
                          logic: LogicBody(isIntangible: true),
                          animations: [],
                          at: .init(x: startingCoordinate.x, y: startingCoordinate.y + 3))
            
            map.addObject(backgroundElement(collision: collision),
                          image: "springTreeTopLeft",
                          filteringMode: .nearest,
                          logic: LogicBody(isIntangible: true),
                          animations: [],
                          at: .init(x: startingCoordinate.x, y: startingCoordinate.y + 6))
            
            map.addObject(backgroundElement(collision: collision),
                          image: "springTreeTopRight",
                          filteringMode: .nearest,
                          logic: LogicBody(isIntangible: true),
                          animations: [],
                          at: .init(x: startingCoordinate.x, y: startingCoordinate.y + 7))
            
            startingCoordinate.y += 10
        }
    }
    
    private func createContainers() {
        if let level = scene.game?.level {
            for container in level.containers {
                let coordinate = container.coordinate.coordinate
                createContainer(container, at: coordinate)
            }
        }
    }
    
    func createContainer(_ container: GameObjectContainer, at coordinate: Coordinate) {
        if let dataObject = try? GameObject.get(container.name) {
            let collision = Collision(category: .object,
                                      collision: [.player, .structure],
                                      contact: [.playerProjectile, .enemyProjectile])
            let logic = LogicBody(health: dataObject.logic.health, damage: dataObject.logic.damage, isDestructible: dataObject.logic.isDestructible, isIntangible: dataObject.logic.isIntangible)
            guard let death = dataObject.animation.first(where: { $0.identifier == "death" }) else { return }
            let animations = [
                ObjectAnimation(identifier: death.identifier, frames: death.frames)
            ]
            
            let objectNode = PKObjectNode()
            objectNode.name = dataObject.name
            objectNode.size = dimension.tileSize
            objectNode.applyPhysicsBody(size: dimension.tileSize, collision: collision)
            objectNode.physicsBody?.isDynamic = false
            
            map.addObject(objectNode,
                          image: dataObject.image,
                          filteringMode: .nearest,
                          logic: logic,
                          animations: animations,
                          at: coordinate)
        }
    }
    func createSphere(at coordinate: Coordinate) {
        let collision = Collision(category: .object,
                                  collision: [.structure],
                                  contact: [.player])
        
        let sphereNode = object(name: "Sphere",
                                physicsBodySizeTailoring: -(dimension.tileSize.width / 2),
                                collision: collision)
        sphereNode.texture = SKTexture(imageNamed: "sphere")
        sphereNode.texture?.filteringMode = .nearest
        let position = map.tilePosition(from: coordinate)
        sphereNode.position = position ?? .zero
        scene.addChildSafely(sphereNode)
    }
    
    func addPortalRequirement(node: PKObjectNode) {
        let portalRequirementNode = SKNode()
        portalRequirementNode.name = "Portal Requirement"
//        if let requirement = scene.game?.level?.requirement {
//            requirement.intoSprites(with: "indicator",
//                                    filteringMode: .nearest,
//                                    spacing: 0.5,
//                                    of: CGSize(width: 50, height: 50),
//                                    at: CGPoint(x: 0, y: dimension.tileSize.height),
//                                    on: portalRequirementNode)
//            node.addChild(portalRequirementNode)
//        }
    }
    
    public func showInteractionMessage() {
        guard let statue = scene.game?.level?.statue else { return }
        
        if let position = map.tilePosition(from: statue.coordinates[0].coordinate) {
            let finalPosition = CGPoint(x: position.x + (dimension.tileSize.width / 2), y: position.y + dimension.tileSize.height)
            createInteractionMessage(buttonSymbol: .x, position: finalPosition)
        }
    }
    
    private func createInteractionMessage(buttonSymbol: ControllerManager.ButtonSymbol, position: CGPoint) {
        //guard let buttonName = scene.game?.controller?.manager?.buttonName(buttonSymbol) else { return }
        
        let interactionNode = SKNode()
        interactionNode.name = "Interaction"
        scene.addChildSafely(interactionNode)
        
        let buttonNode = SKSpriteNode(imageNamed: "triangleButton")
        buttonNode.texture?.filteringMode = .nearest
        buttonNode.size = dimension.tileSize
        buttonNode.position = position
        interactionNode.addChildSafely(buttonNode)
        
        let action = SKAction.scaleUpAndDown(from: 0.8,
                                             with: 0.5,
                                             to: 1,
                                             with: 0.5,
                                             during: 0,
                                             isRepeatingForever: true)
        
        buttonNode.run(action)
    }
    
    /// Pause the map
    public func pause() { map.isPaused = true }
    /// Unpause the map
    public func unpause() { map.isPaused = false }
}
