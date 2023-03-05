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
        let objects = map.objects.filter { !$0.logic.isIntangible }
        let coordinates = objects.map { $0.coordinate }
        return coordinates
    }
    public var levelRequirement: Int {
        let crates = map.objects.filter { $0.name == "Crate" }
        return crates.count
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
        
        createCrate(at: .init(x: 13, y: 11))
        createCrate(at: .init(x: 13, y: 30))
        createCrate(at: .init(x: 10, y: 35))
        
        if let portalCoordinate = scene.game?.level?.exitCoordinate.coordinate {
            createPortal(at: portalCoordinate)
        }
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
    private func createWall() {
        let coordinate = Coordinate(x: 7, y: 0)
        let matrix = Matrix(row: 7, column: 9)
        
        map.addObject(structureElement,
                      image: "blackCrate",
                      filteringMode: .nearest,
                      logic: LogicBody(),
                      animations: [],
                      matrix: matrix,
                      startingCoordinate: coordinate)
        /*map.addObject(structureElement,
                      structure: .init(
                        topLeft: "blackCrate",
                        topRight: "blackCrate",
                        bottomLeft: "blackCrate",
                        bottomRight: "blackCrate",
                        left: "blackCrate",
                        right: "blackCrate",
                        top: "blackCrate",
                        bottom: "blackCrate",
                        middle: "blackCrate"),
                      filteringMode: .nearest,
                      logic: LogicBody(),
                      animations: [],
                      startingCoordinate: coordinate,
                      matrix: Matrix(row: 4, column: 8))*/
    }
    
    func createCrate(at coordinate: Coordinate) {
        if let dataObject = try? GameObject.get("Crate") {
            let collision = Collision(category: .object,
                                      collision: [.player, .structure],
                                      contact: [.playerProjectile, .enemyProjectile])
            let logic = LogicBody(health: dataObject.logic.health, damage: dataObject.logic.damage, isDestructible: dataObject.logic.isDestructible)
            guard let hit = dataObject.animation.first(where: { $0.identifier == "hit" }) else { return }
            guard let death = dataObject.animation.first(where: { $0.identifier == "death" }) else { return }
            let animations = [
                ObjectAnimation(identifier: hit.identifier, frames: hit.frames),
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
    func createPortal(at coordinate: Coordinate) {
        if let dataObject = try? GameObject.get("Portal") {
            let logic = LogicBody(health: dataObject.logic.health,
                                  damage: dataObject.logic.damage,
                                  isDestructible: dataObject.logic.isDestructible,
                                  isIntangible: dataObject.logic.isIntangible)
            
            guard let close = dataObject.animation.first(where: { $0.identifier == "close" }) else { return }
            guard let open = dataObject.animation.first(where: { $0.identifier == "open" }) else { return }
            
            let animations = [
                ObjectAnimation(identifier: close.identifier, frames: close.frames),
                ObjectAnimation(identifier: open.identifier, frames: open.frames)
            ]
            
            let objectNode = PKObjectNode()
            objectNode.name = "Portal"
            objectNode.logic = logic
            objectNode.size = dimension.tileSize
            objectNode.animations = animations
            
            map.addUniqueObject(objectNode, at: coordinate)
            
            let action = objectNode.animatedAction(with: "close", filteringMode: .nearest, timeInterval: 0.1, isRepeatingForever: true)
            
            objectNode.run(action)
            
            addPortalRequirement(node: objectNode)
        }
    }
    func createPortalEnergy(at coordinate: Coordinate, action: ((PKObjectNode) -> Void)?) {
        if let dataObject = try? GameObject.get("Portal Energy") {
            
            let logic = LogicBody(health: dataObject.logic.health,
                                  damage: dataObject.logic.damage,
                                  isDestructible: dataObject.logic.isDestructible,
                                  isIntangible: dataObject.logic.isIntangible)
            
            guard let idle = dataObject.animation.first(where: { $0.identifier == "idle" }) else { return }
            
            let animations = [
                ObjectAnimation(identifier: idle.identifier, frames: idle.frames)
            ]
            
            let objectNode = PKObjectNode()
            objectNode.name = "Portal Energy"
            objectNode.logic = logic
            objectNode.size = dimension.tileSize
            objectNode.animations = animations
            
            map.addUniqueObject(objectNode, at: coordinate)
            
            action?(objectNode)
            
//            let action = objectNode.animatedAction(with: "idle", filteringMode: .nearest, timeInterval: 0.1)
//
//            objectNode.run(action)
        }
    }
    
    func addPortalRequirement(node: PKObjectNode) {
        let portalRequirementNode = SKNode()
        portalRequirementNode.name = "Portal Requirement"
        if let requirement = scene.game?.level?.requirement {
            requirement.intoSprites(with: "indicator",
                                    filteringMode: .nearest,
                                    spacing: 0.5,
                                    of: CGSize(width: 50, height: 50),
                                    at: CGPoint(x: 0, y: dimension.tileSize.height),
                                    on: portalRequirementNode)
            node.addChild(portalRequirementNode)
        }
    }
    
    /// Pause the map
    public func pause() { map.isPaused = true }
    /// Unpause the map
    public func unpause() { map.isPaused = false }
}
