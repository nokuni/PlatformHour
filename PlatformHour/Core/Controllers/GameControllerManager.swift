//
//  GameControllerManager.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 31/01/23.
//

import SpriteKit
import GameController

final public class GameControllerManager {
    
    init(scene: GameScene,
         state: GameState,
         dimension: GameDimension,
         environment: GameEnvironment,
         content: GameContent) {
        self.scene = scene
        self.state = state
        self.environment = environment
        self.content = content
        self.action = ActionLogic(scene: scene , state: state, environment: environment, content: content)
        self.virtualController = GameVirtualController(scene: scene, dimension: dimension, action: action)
        
        print("Game Controller initialized ...")
        virtualController.create()
        observeForGameControllers()
        connectControllers()
    }
    
    enum Button: String, CaseIterable {
        case a
        case b
        
        var image: String {
            switch self {
            case .a: return "buttonA"
            case .b: return "buttonB"
            }
        }
    }
    
    var scene: GameScene
    var state: GameState
    var environment: GameEnvironment
    var content: GameContent
    var action: ActionLogic
    var virtualController: GameVirtualController
    
    private func observeForGameControllers() {
        print("Observe game controllers...")
        NotificationCenter.default.addObserver(self, selector: #selector(connectControllers), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    @objc private func connectControllers() {
//        if !GCController.controllers().isEmpty {
//            virtualController.remove()
//        }
        scene.isPaused = false
        print("Controller connected ...")
        
        if let currentGameController = GCController.current {
            setupControllerControls(controller: currentGameController)
        }
    }
    
    @objc private func disconnectControllers() {
        // Pause the Game if a controller is disconnected ~ This is mandated by Apple
        virtualController.create()
        action.pause()
        print("Controller disconnected ...")
    }
    
    private func setupControllerControls(controller: GCController) {
        //Function that check the controller when anything is moved or pressed on it
        controller.extendedGamepad?.valueChangedHandler = {
            (gamepad: GCExtendedGamepad, element: GCControllerElement) in
            // Add movement in here for sprites of the controllers
            self.controllerInputDetected(gamepad: gamepad, element: element, index: controller.playerIndex.rawValue)
        }
    }
    
    private func pressButton(_ button: GCControllerButtonInput, action: (() -> Void)) {
        if button.isPressed { action() }
    }
    
    private func pressDirection(with directionPad: GCControllerDirectionPad) {
        if directionPad.right.isPressed && !directionPad.left.isPressed { action.moveRight() }
        if directionPad.left.isPressed && !directionPad.right.isPressed { action.moveLeft() }
        
        if directionPad.up.isPressed && !directionPad.down.isPressed {
            if !action.isAttacking {
                scene.player.orientation = .up
                action.switchPlayerArrowDirection()
            }
        }
        if directionPad.down.isPressed && !directionPad.up.isPressed {
            if !action.isAttacking {
                scene.player.orientation = .down
                action.switchPlayerArrowDirection()
            }
        }
    }
    
    private func controllerInputDetected(gamepad: GCExtendedGamepad,
                                 element: GCControllerElement,
                                 index: Int) {
        pressButton(gamepad.buttonMenu) {
            print("Menu pressed")
            action.pause()
        }
        pressButton(gamepad.buttonA) {
            print("A pressed")
            action.jump() }
        pressButton(gamepad.buttonB) {
            print("B pressed")
            action.attack()
        }
        pressButton(gamepad.buttonX) {
            print("X pressed")
        }
        pressButton(gamepad.buttonY) {
            print("Y pressed")
        }
        pressDirection(with: gamepad.dpad)
    }
}
