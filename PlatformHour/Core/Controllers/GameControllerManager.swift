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
    
    public init(scene: GameScene) {
        self.scene = scene
        self.action = ActionLogic(scene: scene)
        print("Game Controller initialized ...")
        setupControllers()
    }
    
    public var scene: GameScene
    public var action: ActionLogic
    
    public var manager: ControllerManager?
    
    public var isLongPressingDPad: Bool = false
    public var isLongPressingButtonA: Bool = false
    public var isLongPressingButtonB: Bool = false
    public var isLongPressingButtonX: Bool = false
    public var isLongPressingButtonY: Bool = false
    
    private func releaseDPad() {
        isLongPressingDPad = false
    }
    private func releaseButtonA() {
        isLongPressingButtonA = false
    }
    private func releaseButtonB() {
        isLongPressingButtonB = false
    }
    private func releaseButtonX() {
        isLongPressingButtonX = false
    }
    private func releaseButtonY() {
        isLongPressingButtonY = false
    }
    
    /// Setup the actions on the gamepad controller
    public func setupActions() {
        manager?.action = ControllerManager.ControllerAction()
        
        // Cross
        manager?.action?.buttonA = ControllerManager.ButtonAction(press: action.actionA,
                                                                  release: releaseButtonA)
        
        // Circle
        manager?.action?.buttonB = ControllerManager.ButtonAction(press: action.actionB,
                                                                  release: releaseButtonB)
        
        // Square
        manager?.action?.buttonX = ControllerManager.ButtonAction(press: action.actionX,
                                                                  release: releaseButtonX)
        
        // Triangle
        manager?.action?.buttonY = ControllerManager.ButtonAction(press: action.actionY,
                                                                  release: releaseButtonY)
        
        manager?.action?.dpad = ControllerManager.DPadAction(leftPress: action.leftPadAction,
                                                             rightPress: action.rightPadAction,
                                                             upPress: action.upPadAction,
                                                             downPress: action.downPadAction,
                                                             release: releaseDPad)
    }
    
    /// Setup the controllers
    private func setupControllers() {
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
