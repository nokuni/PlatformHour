//
//  GameControllerManager.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 31/01/23.
//

import SpriteKit
import GameController
import PlayfulKit

final public class GameControllerManager {
    
    public init(scene: GameScene, state: GameState) {
        self.scene = scene
        self.action = ActionLogic(scene: scene)
        setupControllers()
    }
    
    public var scene: GameScene
    public var action: ActionLogic
    
    public var manager: ControllerManager?
}

// MARK: - Setups

public extension GameControllerManager {
    
    /// Setup the actions on the gamepad controller
    func setupActions() {
        manager?.action = ControllerManager.ControllerAction()
        
        // Cross
        manager?.action?.buttonA = ControllerManager.ButtonAction(press: action.actionA,
                                                                  release: nil)
        
        // Circle
        manager?.action?.buttonB = ControllerManager.ButtonAction(press: action.actionB,
                                                                  release: nil)
        
        // Square
        manager?.action?.buttonX = ControllerManager.ButtonAction(press: action.actionX,
                                                                  release: nil)
        
        // Triangle
        manager?.action?.buttonY = ControllerManager.ButtonAction(press: nil,
                                                                  release: action.actionY)
        
        manager?.action?.dpad = ControllerManager.DPadAction(leftPress: action.leftPadAction,
                                                             rightPress: action.rightPadAction,
                                                             upPress: action.upPadAction,
                                                             downPress: action.downPadAction,
                                                             release: action.releaseDPad)
    }
    
    /// Setup the controllers
    func setupControllers() {
        manager = ControllerManager(scene: scene)
        setupVirtualController()
        setupActions()
        manager?.observeControllers()
    }
    
    /// Setup the virtual controller.
    private func setupVirtualController() {
        manager?.virtualControllerElements = [.directionPad, .buttonA, .buttonB, .buttonX, .buttonY]
    }
}

// MARK: - Actions

public extension GameControllerManager {
    
    /// Disconnect the virtual controller, remove all controller observers and disable touch events.
    func disable() {
        manager?.disableVirtualController()
        manager?.disconnectVirtualController()
        scene.isUserInteractionEnabled = false
    }
    
    /// Disconnect the virtual controller, remove all controller observers and disable touch events.
    func enable() {
        manager?.enableVirtualController()
        manager?.connectVirtualController()
        scene.isUserInteractionEnabled = true
    }
}
