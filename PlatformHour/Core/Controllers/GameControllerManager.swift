//
//  GameControllerManager.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 31/01/23.
//

import SpriteKit
import GameController
import PlayfulKit

final class GameControllerManager {
    
    init(scene: GameScene, state: GameState) {
        self.scene = scene
        self.action = ActionLogic(scene: scene)
        setupControllers()
    }
    
    var scene: GameScene
    var action: ActionLogic
    
    var manager: ControllerManager?
    var controllerButtonState: ControllerButtonState = .none
    
    enum ControllerButtonState {
        case pressed
        case released
        case none
    }
}

// MARK: - Setups

extension GameControllerManager {
    
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
        
        manager?.action?.dpad = ControllerManager.DPadAction(leftPress: action.leftPadActionPress,
                                                             rightPress: action.rightPadActionPress,
                                                             upPress: action.upPadActionPress,
                                                             downPress: action.downPadActionPress,
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

extension GameControllerManager {
    
    /// Disconnect the virtual controller, remove all controller observers and disable touch events.
    func disable(isUserInteractionEnabled: Bool = false) {
        guard let manager = manager else { return }
        guard manager.isVirtualControllerEnabled else { return }
        
        manager.disableVirtualController()
        manager.disconnectVirtualController()
        scene.isUserInteractionEnabled = isUserInteractionEnabled
    }
    
    /// Disconnect the virtual controller, remove all controller observers and disable touch events.
    func enable(isUserInteractionEnabled: Bool = true) {
        guard let manager = manager else { return }
        guard !manager.isVirtualControllerEnabled else { return }
        
        manager.enableVirtualController()
        manager.connectVirtualController()
        scene.isUserInteractionEnabled = isUserInteractionEnabled
    }
}
