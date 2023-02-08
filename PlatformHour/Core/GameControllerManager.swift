//
//  GameControllerManager.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 31/01/23.
//

import SpriteKit
import GameController

final public class GameControllerManager: ObservableObject {
    
    init(scene: SKScene) {
        self.scene = scene
        action = ActionLogic(scene: scene, controller: self)
        virtual = GameVirtualController(scene: scene, controller: self)
        observeForGameControllers()
        virtual?.createVirtualGameController()
    }
    
    enum Direction: String, CaseIterable {
        case none
        case up
        case down
        case right
        case left
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
    
    @Published var direction: Direction = .none
    @Published var isMoving: Bool = false
    @Published var isJumping: Bool = false
    
    var scene: SKScene?
    var action: ActionLogic?
    var virtual: GameVirtualController?
    var timer: Timer?
    
    func observeForGameControllers() {
        print("Observe Game Controllers")
        NotificationCenter.default.addObserver(self, selector: #selector(connectControllers), name: NSNotification.Name.GCControllerDidConnect, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(disconnectControllers), name: NSNotification.Name.GCControllerDidDisconnect, object: nil)
    }
    
    @objc func connectControllers() {
        // Unpause the Game if it is currently paused
        scene?.isPaused = false
        print("Controller connected ...")
        //Used to register the Nimbus Controllers to a specific Player Number
        var indexNumber = 0
        // Run through each controller currently connected to the system
        virtual?.removeVirtualGameControler()
        let hasConnectedControllers = !GCController.controllers().isEmpty
        print(hasConnectedControllers)
        if hasConnectedControllers {
            for controller in GCController.controllers() {
                //Check to see whether it is an extended Game Controller (Such as a Nimbus)
                if controller.extendedGamepad != nil {
                    controller.playerIndex = GCControllerPlayerIndex.init(rawValue: indexNumber)!
                    indexNumber += 1
                    setupControllerControls(controller: controller)
                }
            }
        } else {
            virtual?.createVirtualGameController()
        }
    }
    
    @objc func disconnectControllers() {
        // Pause the Game if a controller is disconnected ~ This is mandated by Apple
        virtual?.createVirtualGameController()
        action?.pause()
        print("Controller disconnected ...")
    }
    
    func setupControllerControls(controller: GCController) {
        //Function that check the controller when anything is moved or pressed on it
        controller.extendedGamepad?.valueChangedHandler = {
            (gamepad: GCExtendedGamepad, element: GCControllerElement) in
            // Add movement in here for sprites of the controllers
            self.controllerInputDetected(gamepad: gamepad, element: element, index: controller.playerIndex.rawValue)
        }
    }
    
    func pressButton(_ button: GCControllerButtonInput, action: (() -> Void)) {
        if button.isPressed { action() }
    }
    
    func pressDirection(with directionPad: GCControllerDirectionPad) {
        action?.horizontal(right: directionPad.right.value, left: directionPad.left.value)
    }
    
    func controllerInputDetected(gamepad: GCExtendedGamepad, element: GCControllerElement, index: Int) {
        pressButton(gamepad.buttonMenu) { action?.pause() }
        pressButton(gamepad.buttonA) { action?.jump() }
        pressButton(gamepad.buttonB) { }
        pressButton(gamepad.buttonX) { }
        pressButton(gamepad.buttonY) { }
        pressDirection(with: gamepad.dpad)
    }
}
