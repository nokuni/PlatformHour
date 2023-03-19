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
    
    public init(scene: GameScene) {
        self.scene = scene
        createEnvironment()
    }
    
    public var scene: GameScene
    public var map = PKMapNode()
    public var backgroundContainer = SKNode()
    public var mountainsContainer = SKNode()
    
    public var allElements: [SKSpriteNode] {
        let allTiles = map.tiles
        let allObjects = map.objects
        let allElements = allTiles + allObjects
        return allElements
    }
    
    public var collisionCoordinates: [Coordinate] {
        let objects = map.objects.filter { !$0.logic.isIntangible }
        let coordinates = objects.map { $0.coordinate }
        return coordinates
    }
    
    // MARK: - Main
    private func createEnvironment() {
        createMap()
        backgroundContainer.name = "Background"
        scene.addChildSafely(backgroundContainer)
        
        let tileSize = GameConfiguration.worldConfiguration.tileSize
        
        guard let startingPosition = map.tilePosition(from: Coordinate(x: 4, y: 4)) else { return }
        var backgrounds: [SKSpriteNode] = []
        for _ in 0..<3 {
            let background = SKSpriteNode(imageNamed: "springDaySky")
            background.size = CGSize(width: tileSize.width * 13, height: tileSize.height * 9)
            background.texture?.filteringMode = .nearest
            backgrounds.append(background)
        }
        GameConfiguration.assemblyManager.createSpriteList(of: backgrounds, at: startingPosition, in: backgroundContainer, axes: .horizontal, adjustement: .leading, spacing: 1)
        
        print(backgroundContainer.position)
        
        //createBackground()
    }
    
    // MARK: - Elements
    public func objectElement(name: String? = nil,
                              physicsBodySizeTailoring: CGFloat = 0,
                              collision: Collision) -> PKObjectNode {
        
        let object = PKObjectNode()
        object.name = name
        object.size = GameConfiguration.worldConfiguration.tileSize
        
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
        structureElement.zPosition = 2
        structureElement.physicsBody?.friction = 0
        structureElement.physicsBody?.isDynamic = false
        structureElement.physicsBody?.affectedByGravity = false
        structureElement.physicsBody?.usesPreciseCollisionDetection = true
        return structureElement
    }
    
    public func backgroundObjectElement(name: String? = nil,
                                        physicsBodySizeTailoring: CGFloat = 0,
                                        collision: Collision) -> PKObjectNode {
        let structureElement = objectElement(name: name,
                                             physicsBodySizeTailoring: physicsBodySizeTailoring,
                                             collision: collision)
        structureElement.name = name
        structureElement.zPosition = 1
        structureElement.physicsBody?.isDynamic = false
        structureElement.physicsBody?.affectedByGravity = false
        return structureElement
    }
    
    // MARK: - Background
    private func createBackground() {
        createMountains()
    }
    
    private func createMap() {
        map = PKMapNode(squareSize: GameConfiguration.worldConfiguration.tileSize,
                        matrix: Game.mapMatrix)
        scene.addChild(map)
    }
    
    private func createMountains() {
//        let array = 0..<Game.mapMatrix.column
//        let coordinates = array.map { Coordinate(x: 13, y: $0) }
//        let leftCoordinates = coordinates.filter { $0.y.isEven }
//        let rightCoordinates = coordinates.filter { $0.y.isOdd }
//
//        map.addChildSafely(mountainsContainer)
//
//        guard let startingPosition = map.tilePosition(from: Coordinate(x: 13, y: 0)) else { return }
//
//        var mountains: [SKSpriteNode] = []
//        for index in 0..<30 {
//            let mountain = SKSpriteNode(imageNamed: index.isEven ? "mountainsLeft" : "mountainsRight")
//            mountain.texture?.filteringMode = .nearest
//            mountain.size = GameConfiguration.worldConfiguration.tileSize
//            mountains.append(mountain)
//        }
//
//        GameConfiguration.assemblyManager.createSpriteList(of: mountains, at: startingPosition, in: mountainsContainer, axes: .horizontal, adjustement: .leading, spacing: 1)
        
//        map.drawTexture("mountainsLeft",
//                        filteringMode: .nearest,
//                        row: 13, excluding: rightCoordinates)
//        map.drawTexture("mountainsRight",
//                        filteringMode: .nearest,
//                        row: 13, excluding: leftCoordinates)
    }
    
    // MARK: - Miscellaneous
    private func controllerButtonSprites(_ buttonSymbol: ControllerManager.ButtonSymbol) -> [String]? {
        guard let controllerManager = scene.game?.controller?.manager else {
            return nil
        }
        switch buttonSymbol {
        case .a:
            switch controllerManager.currentProductCategory {
            case .xbox:
                return ControllerButton.button(.a, of: .xbox)
            case .playstation:
                return ControllerButton.button(.a, of: .playstation)
            case .nintendo:
                return ControllerButton.button(.a, of: .nintendo)
            case .none:
                return ControllerButton.button(.a, of: .nintendo)
            }
        case .b:
            switch controllerManager.currentProductCategory {
            case .xbox:
                return ControllerButton.button(.b, of: .xbox)
            case .playstation:
                return ControllerButton.button(.b, of: .playstation)
            case .nintendo:
                return ControllerButton.button(.b, of: .nintendo)
            case .none:
                return ControllerButton.button(.b, of: .nintendo)
            }
        case .x:
            switch controllerManager.currentProductCategory {
            case .xbox:
                return ControllerButton.button(.x, of: .xbox)
            case .playstation:
                return ControllerButton.button(.x, of: .playstation)
            case .nintendo:
                return ControllerButton.button(.x, of: .nintendo)
            case .none:
                return ControllerButton.button(.x, of: .nintendo)
            }
        case .y:
            switch controllerManager.currentProductCategory {
            case .xbox:
                return ControllerButton.button(.y, of: .xbox)
            case .playstation:
                return ControllerButton.button(.y, of: .playstation)
            case .nintendo:
                return ControllerButton.button(.y, of: .nintendo)
            case .none:
                return ControllerButton.button(.y, of: .nintendo)
            }
        }
    }
    
    public func showStatueInteractionPopUp() {
        guard let player = scene.player else { return }
        guard let statue = scene.game?.level?.statue else { return }
        
        if let position = map.tilePosition(from: statue.coordinates[0].coordinate) {
            let requirementPosition = CGPoint(x: position.x + (GameConfiguration.worldConfiguration.tileSize.width * 0.75), y: position.y + (GameConfiguration.worldConfiguration.tileSize.height * 0.5))
            let buttonPosition = CGPoint(x: position.x + (GameConfiguration.worldConfiguration.tileSize.width * 0.5), y: position.y + (GameConfiguration.worldConfiguration.tileSize.height * 1.5))
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
        button.size = GameConfiguration.worldConfiguration.tileSize
        button.setScale(0.6)
        button.position = position
        buttonPopUp.addChildSafely(button)
        
        if let sprites = controllerButtonSprites(buttonSymbol) {
            let action = SKAction.animate(with: sprites, filteringMode: .nearest, timePerFrame: 0.5)
            button.run(SKAction.repeatForever(action))
        }
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
        number.size = GameConfiguration.worldConfiguration.tileSize
        number.position = CGPoint(x: -GameConfiguration.worldConfiguration.tileSize.width, y: 0)
        requirementPopUp.addChildSafely(number)
        
        let item = SKSpriteNode(imageNamed: "hudSphere")
        item.texture?.filteringMode = .nearest
        item.size = GameConfiguration.worldConfiguration.tileSize
        item.position = .zero
        requirementPopUp.addChildSafely(item)
    }
    
    public func pause() { map.isPaused = true }
    
    public func unpause() { map.isPaused = false }
}
