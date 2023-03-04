//
//  GameEnvironment.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

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
        let coordinates = map.objects.map { $0.coordinate }
        return coordinates
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
    var structureElement: PKObjectNode {
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
    
    // MARK: - Creations
    private func createEnvironment() {
        createMap()
        createSky()
        createGround()
        createWall()
        
        createObject("Crate", at: .init(x: 13, y: 18))
        createObject("Crate", at: .init(x: 13, y: 19))
        createObject("Crate", at: .init(x: 13, y: 20))
    }
    
    private func createMap() {
        map = PKMapNode(squareSize: dimension.tileSize,
                        matrix: mapMatrix)
        scene.addChild(map)
    }
    private func createSky() {
        if let world = scene.game.world {
            let matrix = Matrix(row: mapMatrix.row - 4, column: mapMatrix.column)
            map.drawTexture(world.skyName,
                            filteringMode: .nearest,
                            matrix: matrix,
                            startingCoordinate: Coordinate.zero)
        }
    }
    private func createGround() {
        let coordinate = Coordinate(x: 14, y: 0)
        
        if let world = scene.game.world {
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
    private func createWall() {
        let coordinate = Coordinate(x: 10, y: 1)
        
        map.addObject(structureElement,
                      structure: .init(
                        topLeft: "templeWallTopLeft",
                        topRight: "templeWallTopRight",
                        bottomLeft: "templeWallBottomLeft",
                        bottomRight: "templeWallBottomRight",
                        left: "templeWallLeft",
                        right: "templeWallRight",
                        top: "templeWallTop",
                        bottom: "templeWallBottom",
                        middle: "templeWallMiddle"),
                      filteringMode: .nearest,
                      logic: LogicBody(),
                      animations: [],
                      startingCoordinate: coordinate,
                      matrix: Matrix(row: 4, column: 8))
    }
    
    func createObject(_ name: String, at coordinate: Coordinate) {
        if let dataObject = try? GameObject.get(name) {
            let collision = Collision(category: .object,
                                      collision: [.player, .structure],
                                      contact: [.playerProjectile, .enemyProjectile])
            let logic = LogicBody(health: dataObject.logic.health, damage: dataObject.logic.damage, isDestructible: dataObject.logic.isDestructible)
            let animations = [
                ObjectAnimation(identifier: GameAnimation.StateID.hit.rawValue,
                                frames: dataObject.animation.hit),
                ObjectAnimation(identifier: GameAnimation.StateID.death.rawValue,
                                frames: dataObject.animation.death)
            ]
            
            let objectNode = PKObjectNode()
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
    
    /// Pause the map
    public func pause() { map.isPaused = true }
    /// Unpause the map
    public func unpause() { map.isPaused = false }
}
