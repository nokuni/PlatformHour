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

final public class GameEnvironment {
    
    public init(scene: GameScene,
                dimension: GameDimension) {
        self.scene = scene
        self.dimension = dimension
        createEnvironment()
    }
    
    public var scene: GameScene
    public var dimension: GameDimension
    public var map = PKMapNode()
    
    public var collisionCoordinates: [Coordinate] {
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
    
    // MARK: - Main
    private func createEnvironment() {
        createMap()
        createBackground()
    }
    
    // MARK: - Elements
    public func objectElement(name: String? = nil,
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

    public var structureObjectElement: PKObjectNode {
        let collision = Collision(category: .structure,
                                  collision: [.player, .object, .playerProjectile, .enemyProjectile],
                                  contact: [.player, .object, .playerProjectile, .enemyProjectile])
        let structureElement = objectElement(collision: collision)
        structureElement.physicsBody?.friction = 0
        structureElement.physicsBody?.isDynamic = false
        structureElement.physicsBody?.affectedByGravity = false
        structureElement.physicsBody?.usesPreciseCollisionDetection = true
        return structureElement
    }

    public func backgroundObjectElement(name: String? = nil, collision: Collision) -> PKObjectNode {
        let structureElement = objectElement(collision: collision)
        structureElement.name = name
        structureElement.physicsBody?.isDynamic = false
        structureElement.physicsBody?.affectedByGravity = false
        return structureElement
    }
    
    // MARK: - Background
    private func createBackground() {
        createSky()
        createClouds()
        createMountains()
    }
    
    private func createMap() {
        map = PKMapNode(squareSize: dimension.tileSize,
                        matrix: Game.mapMatrix)
        scene.addChild(map)
    }

    private func createSky() {
        if let world = scene.game?.world {
            let matrix = Matrix(row: Game.mapMatrix.row - 4, column: Game.mapMatrix.column)
            map.drawTexture(world.skyName,
                            filteringMode: .nearest,
                            matrix: matrix,
                            startingCoordinate: Coordinate.zero)
        }
    }

    private func createClouds() {
        var firstStartingCoordinate = Coordinate(x: 9, y: 0)
        for _ in 0..<3 {
            
            map.drawTexture("cloud0Left",
                            filteringMode: .nearest,
                            at: .init(x: firstStartingCoordinate.x, y: firstStartingCoordinate.y))
            
            map.drawTexture("cloud0Middle",
                            filteringMode: .nearest,
                            at: .init(x: firstStartingCoordinate.x, y: firstStartingCoordinate.y + 1))
            
            map.drawTexture("cloud0Right",
                            filteringMode: .nearest,
                            at: .init(x: firstStartingCoordinate.x, y: firstStartingCoordinate.y + 2))
            
            firstStartingCoordinate.y += 20
        }
        var secondStartingCoordinate = Coordinate(x: 10, y: 5)
        for _ in 0..<6 {
            map.drawTexture("cloud1Left",
                            filteringMode: .nearest,
                            at: .init(x: secondStartingCoordinate.x, y: secondStartingCoordinate.y))
            
            map.drawTexture("cloud1Middle",
                            filteringMode: .nearest,
                            at: .init(x: secondStartingCoordinate.x, y: secondStartingCoordinate.y + 1))
            
            map.drawTexture("cloud1Right",
                            filteringMode: .nearest,
                            at: .init(x: secondStartingCoordinate.x, y: secondStartingCoordinate.y + 2))
            
            secondStartingCoordinate.y += 10
        }
    }

    private func createMountains() {
        let array = 0..<Game.mapMatrix.column
        let coordinates = array.map { Coordinate(x: 13, y: $0) }
        let leftCoordinates = coordinates.filter { $0.y.isEven }
        let rightCoordinates = coordinates.filter { $0.y.isOdd }
        
        map.drawTexture("mountainsLeft",
                        filteringMode: .nearest,
                        row: 13, excluding: rightCoordinates)
        map.drawTexture("mountainsRight",
                        filteringMode: .nearest,
                        row: 13, excluding: leftCoordinates)
    }
    
    // MARK: - Miscellaneous
    private func controllerButtonSprites(_ buttonSymbol: ControllerManager.ButtonSymbol) -> [String] {
        guard let controllerManager = scene.game?.controller?.manager else { return [] }
        guard let currentProductCategory = controllerManager.currentProductCategory else { return [] }
        switch buttonSymbol {
        case .a:
            switch currentProductCategory {
            case .xbox:
                return ["xboxAButtonReleased", "xboxAButtonPressed"]
            case .playstation:
                return ["playstationCrossButtonReleased", "playstationCrossButtonPressed"]
            case .nintendo:
                return ["joyconAButtonReleased", "joyconAButtonPressed"]
            }
        case .b:
            switch currentProductCategory {
            case .xbox:
                return ["xboxBButtonReleased", "xboxBButtonPressed"]
            case .playstation:
                return ["playstationCircleButtonReleased", "playstationCircleButtonPressed"]
            case .nintendo:
                return ["joyconBButtonReleased", "joyconBButtonPressed"]
            }
        case .x:
            switch currentProductCategory {
            case .xbox:
                return ["xboxXButtonReleased", "xboxXButtonPressed"]
            case .playstation:
                return ["playstationSquareButtonReleased", "playstationSquareButtonPressed"]
            case .nintendo:
                return ["joyconXButtonReleased", "joyconXButtonPressed"]
            }
        case .y:
            switch currentProductCategory {
            case .xbox:
                return ["xboxYButtonReleased", "xboxYButtonPressed"]
            case .playstation:
                return ["playstationTriangleButtonReleased", "playstationTriangleButtonPressed"]
            case .nintendo:
                return ["joyconYButtonReleased", "joyconYButtonPressed"]
            }
        }
    }

    public func showStatueInteractionPopUp() {
        guard let player = scene.player else { return }
        guard let statue = scene.game?.level?.statue else { return }
        
        if let position = map.tilePosition(from: statue.coordinates[0].coordinate) {
            let requirementPosition = CGPoint(x: position.x + (dimension.tileSize.width * 0.75), y: position.y + (dimension.tileSize.height * 0.5))
            let buttonPosition = CGPoint(x: position.x + (dimension.tileSize.width * 0.5), y: position.y + (dimension.tileSize.height * 1.5))
            createStatueRequirementPopUp(position: requirementPosition)
            if !player.bag.isEmpty {
                createButtonPopUp(buttonSymbol: .y, position: buttonPosition)
            }
        }
    }

    private func createButtonPopUp(buttonSymbol: ControllerManager.ButtonSymbol, position: CGPoint) {
        
        let buttonPopUp = SKNode()
        buttonPopUp.name = "Button pop up"
        scene.addChildSafely(buttonPopUp)
        
        let button = SKSpriteNode()
        button.size = dimension.tileSize
        button.setScale(0.6)
        button.position = position
        buttonPopUp.addChildSafely(button)


        let action = SKAction.animate(with: controllerButtonSprites(buttonSymbol), filteringMode: .nearest, timePerFrame: 0.5)
        
        button.run(SKAction.repeatForever(action))
    }
    
    private func createStatueRequirementPopUp(position: CGPoint) {
        
        guard let statue = scene.game?.level?.statue else { return }
        guard !statue.requirement.isEmpty else { return }
        
        let requirementPopUp = SKNode()
        requirementPopUp.name = "Requirement pop up"
        requirementPopUp.setScale(0.6)
        requirementPopUp.position = position
        scene.addChildSafely(requirementPopUp)
        
        let number = SKSpriteNode(imageNamed: "indicator\(statue.requirement.count)")
        number.name = "Number"
        number.texture?.filteringMode = .nearest
        number.size = dimension.tileSize
        number.position = CGPoint(x: -dimension.tileSize.width, y: 0)
        requirementPopUp.addChildSafely(number)
        
        let item = SKSpriteNode(imageNamed: "hudSphere")
        item.texture?.filteringMode = .nearest
        item.size = dimension.tileSize
        item.position = .zero
        requirementPopUp.addChildSafely(item)
    }

    public func updateStatueRequirementPopUp() {
        
        guard let statue = scene.game?.level?.statue else { return }
        
        guard let requirementPopUp = scene.childNode(withName: "Requirement pop up") else {
            return
        }
        
        guard let number = requirementPopUp.childNode(withName: "Number") as? SKSpriteNode else {
            return
        }
        
        number.texture = SKTexture(imageNamed: "indicator\(statue.requirement.count)")
        number.texture?.filteringMode = .nearest
    }
    
    public func pause() { map.isPaused = true }

    public func unpause() { map.isPaused = false }
}
