//
//  GameVirtualController.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 03/02/23.
//

import SpriteKit
import PlayfulKit

final public class GameVirtualController: ObservableObject {
    
    init(scene: SKScene, controller: GameControllerManager) {
        self.scene = scene
        self.controller = controller
    }
    
    public var scene: SKScene?
    var controller: GameControllerManager
    
    @Published public var hasPressedAnyInput: Bool = false
    
    private var directionalPadPosition : CGPoint {
        return UIDevice.isOnPhone ?
        CGPoint(x: -CGSize.screen.width * 0.37, y: -CGSize.screen.height * 0.22) :
        CGPoint(x: -CGSize.screen.width * 0.42, y: -CGSize.screen.height * 0.33)
    }
    private var buttonsPosition : CGPoint {
        return UIDevice.isOnPhone ?
        CGPoint(x: CGSize.screen.width * 0.4, y: -CGSize.screen.height * 0.24) :
        CGPoint(x: CGSize.screen.width * 0.45, y: -CGSize.screen.height * 0.35)
    }
    
    private func createDirectionalPadParts(_ padDirections: [GameControllerManager.Direction], _ axes: PKMatrix.PKAxes, _ image: String, on position: CGPoint, in node: SKNode) {
        
        guard let scene = scene as? GameScene else { return }
        guard let dimension = scene.dimension else { return }
        
        var padNodes: [SKSpriteNode] = []
        
        for pad in padDirections {
            let padNode = SKSpriteNode(imageNamed: image)
            padNode.name = pad.rawValue
            padNode.texture?.filteringMode = .nearest
            padNode.alpha = 0.2
            padNode.size = dimension.tileSize
            padNodes.append(padNode)
        }
        
        dimension.kit.createSpriteList(of: padNodes, at: position, in: node, axes: axes, alignment: .leading, spacing: 2)
    }
    
    private func createDirectionalPad(on node: SKNode) {
        guard let scene = scene as? GameScene else { return }
        guard let dimension = scene.dimension else { return }
        
        let directionalPadNode = SKNode()
        directionalPadNode.zPosition = 99
        directionalPadNode.position = directionalPadPosition
        
        node.addChild(directionalPadNode)
        
        createDirectionalPadParts([.left, .right], .horizontal, "horizontalPad", on: CGPoint.zero, in: directionalPadNode)
        
        let verticalPosition = CGPoint(x: dimension.tileSize.width, y: dimension.tileSize.height)
        
        createDirectionalPadParts([.up, .down], .vertical, "verticalPad", on: verticalPosition, in: directionalPadNode)
    }
    private func createButtons(on node: SKNode) {
        guard let scene = scene as? GameScene else { return }
        guard let dimension = scene.dimension else { return }
        
        let buttonsNode = SKNode()
        buttonsNode.zPosition = 99
        buttonsNode.position = buttonsPosition
        
        node.addChild(buttonsNode)
        
        var buttonNodes: [SKSpriteNode] = []
        
        for button in GameControllerManager.Button.allCases {
            let buttonNode = SKSpriteNode(imageNamed: button.image)
            buttonNode.name = button.rawValue
            buttonNode.texture?.filteringMode = .nearest
            buttonNode.alpha = 0.2
            buttonNode.size = dimension.tileSize
            buttonNodes.append(buttonNode)
        }
        
        dimension.kit.createSpriteList(of: buttonNodes, at: CGPoint.zero, in: buttonsNode, axes: .horizontal, alignment: .trailing, spacing: 2)
    }
    
    public func createVirtualGameController() {
        removeVirtualGameControler()
        let virtualControllerNode = SKNode()
        virtualControllerNode.name = "Virtual Game Controller"
        scene?.camera?.addChild(virtualControllerNode)
        createDirectionalPad(on: virtualControllerNode)
        createButtons(on: virtualControllerNode)
    }
    public func removeVirtualGameControler() {
        guard let virtualGameController = scene?.camera?.childNode(withName: "Virtual Game Controller") else { return }
        print("Virtual Game Controller removed")
        virtualGameController.removeFromParent()
    }
    
    func touchButton(_ button: GameControllerManager.Button) {
    if !hasPressedAnyInput {
        hasPressedAnyInput = true
        switch button {
        case .a: controller.action?.jump()
        case .b: controller.action?.teleport()
        }
    }
}
    func touchDirectionalPad(_ direction: GameControllerManager.Direction) {
        guard let scene = scene as? GameScene else { return }
        if !hasPressedAnyInput {
            hasPressedAnyInput = true
            switch direction {
            case .none: print("Tapped None")
            case .up: print("Tapped Up")
            case .down: print("Tapped Down")
            case .right: controller.action?.hold(on: .right, by: scene.player.node.size.width)
            case .left: controller.action?.hold(on: .left, by: -scene.player.node.size.width)
            }
        }
    }
}
