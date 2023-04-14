//
//  ActionLogic.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 02/02/23.
//

import SpriteKit
import PlayfulKit
import Utility_Toolbox

public final class ActionLogic {
    
    public init(scene: GameScene) {
        self.scene = scene
    }
    
    public var scene: GameScene
    
    public var configuration = ActionLogicConfiguration()
}

// MARK: - Directional Actions

public extension ActionLogic {
    
    /// Trigger right pad actions.
    func rightPadAction() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            moveRight()
        case .inAction:
            addSequenceAction(.moveRight)
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger left pad actions.
    func leftPadAction() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            moveLeft()
        case .inAction:
            addSequenceAction(.moveLeft)
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger up pad actions.
    func upPadAction() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            break
        case .inAction:
            addSequenceAction(.moveUp)
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger down pad actions.
    func downPadAction() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            break
        case .inAction:
            addSequenceAction(.moveDown)
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Move the player to the right.
    private func moveRight() {
        guard let player = scene.player else { return }
        guard !player.state.isJumping else { return }
        guard !player.isAnimating else { return }
        guard scene.isUserInteractionEnabled else { return }
        
        let movementSpeed = GameConfiguration.playerConfiguration.movementSpeed
        
        move(on: .right, by: movementSpeed)
    }
    
    /// Move the player to the left.
    private func moveLeft() {
        guard let player = scene.player else { return }
        guard !player.state.isJumping else { return }
        guard !player.isAnimating else { return }
        guard scene.isUserInteractionEnabled else { return }
        
        let movementSpeed = -GameConfiguration.playerConfiguration.movementSpeed
        
        move(on: .left, by: movementSpeed)
    }
}

// MARK: - Button Actions

public extension ActionLogic {
    
    /// Trigger button A actions.
    func actionA() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            jump()
        case .inAction:
            break
        case .inConversation:
            scene.core?.hud?.passLine()
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger button B actions.
    func actionB() {
        
    }
    
    /// Trigger button X actions.
    func actionX() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            attack()
        case .inAction:
            break
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger button Y actions.
    func actionY() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            interact()
        case .inAction:
            break
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Release the Dpad.
    func releaseDPad() {
        configuration.isLongPressingDPad = false
    }
    
    /// Jump.
    private func jump() {
        guard let player = scene.player else { return }
        guard !player.state.isJumping else { return }
        guard player.interactionStatus == .none else { return }
        guard !player.isAnimating else { return }
        
        let action = jumpAction(player: player)
        
        scene.game?.controller?.action.disable()
        player.state.isJumping = true
        player.node.run(action)
    }
    
    /// Attack.
    private func attack() {
        guard let player = scene.player else { return }
        guard !configuration.isAttacking(scene: scene) else { return }
        guard !player.isAnimating else { return }
        guard scene.isUserInteractionEnabled else { return }
        
        if let projectileNode = scene.core?.content?.projectileNode {
            scene.addChild(projectileNode)
            throwProjectile(projectileNode)
        }
    }
    
    /// Interact.
    private func interact() {
        guard let player = scene.player else { return }
        guard scene.isUserInteractionEnabled else { return }
        
        switch player.interactionStatus {
        case .none:
            ()
        case .onExit:
            scene.core?.event?.loadNextLevel()
        }
    }
}

// MARK: - Animations

public extension ActionLogic {
    
    /// Returns the jump animation.
    private func jumpAction(player: Player) -> SKAction {
        let jumpValue = GameConfiguration.playerConfiguration.jumpValue
        let moveUpValue = GameConfiguration.sceneConfiguration.tileSize.height
        let moveUpDestination = CGPoint(x: player.node.position.x,
                                        y: player.node.position.y + moveUpValue)
        let array = stride(from: 0, to: jumpValue, by: 1)
        let destinations = array.map {
            CGPoint(x: moveUpDestination.x, y: moveUpDestination.y + (moveUpValue * $0))
        }
        var actions = destinations.map {
            SKAction.sequence([
                SKAction.move(to: $0, duration: 0.2)
            ])
        }
        
        actions.append(SKAction.run {
            self.scene.core?.animation?.addObjectEffect(keyName: GameConfiguration.nodeKey.sparkEffect,
                                                        scene: self.scene,
                                                        node: player.node,
                                                        timeInterval: 0.1,
                                                        isRepeatingForever: true)
            self.scene.core?.hud?.addActionSquares()
        })
        
        let floatingSequence = SKAction.sequence([
            SKAction.moveBy(x: 0, y: -5, duration: 1),
            SKAction.moveBy(x: 0, y: 5, duration: 1)
        ])
        let floatingAnimation = SKAction.repeatForever(floatingSequence)
        
        actions.append(floatingAnimation)
        
        let jumpSequence = SKAction.sequence(actions)
        
        return jumpSequence
    }
    
    /// Returns the move animation.
    private func moveAction(destinationPosition: CGPoint,
                            destinationCoordinate: Coordinate,
                            amount: Int) -> SKAction {
        guard let player = scene.player else { return SKAction.empty() }
        guard let environment = scene.core?.environment else { return SKAction.empty() }
        let groundCoordinate = Coordinate(x: destinationCoordinate.x + 1, y: destinationCoordinate.y)
        let sequence = SKAction.sequence([
            SKAction.move(to: destinationPosition, duration: player.runDuration),
            endOfMoveAction(groundCoordinate: groundCoordinate)
        ])
        return !environment.collisionCoordinates.contains(destinationCoordinate) ? sequence : SKAction.empty()
    }
    
    /// Returns the end of the move animation.
    private func endOfMoveAction(groundCoordinate: Coordinate) -> SKAction {
        guard let environment = scene.core?.environment else { return SKAction.empty() }
        
        let action = SKAction.run {
            self.scene.core?.sound.step()
            self.scene.player?.node.removeAllActions()
            if !environment.collisionCoordinates.contains(groundCoordinate) {
                self.scene.core?.logic?.dropPlayer()
            }
            self.scene.core?.event?.triggerConversationOnCoordinate()
            //self.scene.core?.event?.playCinematic()
            if self.configuration.isLongPressingDPad {
                self.move(on: self.configuration.direction, by: self.configuration.movementSpeed)
            }
        }
        
        return action
    }
}

// MARK: - Underlying Actions/Animations

public extension ActionLogic {
    
    /// Adds an action to the action sequence.
    private func addSequenceAction(_ action: Player.SequenceAction) {
        guard let player = scene.player else { return }
        guard player.actions.count < player.currentRoll.rawValue else { return }
        player.actions.append(action)
        let actionElement = SKSpriteNode(imageNamed: action.icon)
        actionElement.texture?.filteringMode = .nearest
        actionElement.size = GameConfiguration.sceneConfiguration.tileSize * 0.6
        scene.core?.hud?.actionSquares[safe: player.actions.count - 1]?.addChildSafely(actionElement)
        scene.core?.logic?.resolveSequenceOfActions()
    }
    
    /// Moves the player.
    func move(on direction: ActionLogicConfiguration.Direction, by movementSpeed: Int) {
        guard let player = scene.player else { return }
        guard !player.isAnimating else { return }
        guard !player.state.isJumping else { return }
        guard scene.isUserInteractionEnabled else { return }
        
        configuration.isLongPressingDPad = true
        scene.core?.event?.dismissButtonPopUp()
        self.configuration.direction = direction
        changeOrientation(direction: self.configuration.direction)
        self.configuration.movementSpeed = movementSpeed
        moveSequence(by: self.configuration.movementSpeed)
        scene.player?.advanceRoll()
        scene.player?.run()
    }
    
    /// Throws a projectile.
    private func throwProjectile(_ projectileNode: PKObjectNode) {
        guard let player = scene.player else { return }
        let distanceAmount = CGFloat(player.stats.range)
        var xDistance: CGFloat = 0
        var yDistance: CGFloat = 0
        
        switch player.orientation {
        case .right: xDistance = player.node.size.width * distanceAmount
        case .left: xDistance = -player.node.size.width * distanceAmount
        case .up: yDistance = player.node.size.height * distanceAmount
        case .down: yDistance = -player.node.size.height * distanceAmount
        }
        
        let destination = CGPoint(x: player.node.position.x + xDistance,
                                  y: player.node.position.y + yDistance)
        
        let sequence = SKAction.sequence([
            SKAction.move(to: destination, duration: player.stats.attackSpeed),
            SKAction.run {
                player.state.hasProjectileTurningBack = true
            }
        ])
        
        projectileNode.run(sequence)
    }
    
    /// The player move sequence.
    private func moveSequence(by amount: Int) {
        guard let player = scene.player else { return }
        guard let environment = scene.core?.environment else { return }
        
        let playerCoordinate = player.node.coordinate
        
        let destinationCoordinate = Coordinate(x: playerCoordinate.x,
                                               y: playerCoordinate.y + amount)
        
        guard let destinationPosition = environment.map.tilePosition(from: destinationCoordinate) else { return }
        
        let moveSequence = moveAction(destinationPosition: destinationPosition,
                                      destinationCoordinate: destinationCoordinate, amount: amount)
        
        scene.player?.node.run(moveSequence)
    }
    
    /// Changes the player orientation.
    private func changeOrientation(direction: ActionLogicConfiguration.Direction) {
        switch direction {
        case .right:
            scene.player?.orientation = .right
        case .left:
            scene.player?.orientation = .left
        case .up:
            scene.player?.orientation = .up
        case .down:
            scene.player?.orientation = .down
        case .none:
            ()
        }
    }
}

// MARK: - Miscellaneous

public extension ActionLogic {
    
    /// Pause the game.
    func pause() {
        guard let state = scene.core?.state else { return }
        scene.core?.content?.pause()
        state.switchOn(newStatus: .inPause)
        scene.core?.hud?.createPauseScreen()
    }
    
    /// Unpause the game.
    func unPause() {
        guard let state = scene.core?.state else { return }
        if state.status == .inPause {
            scene.core?.content?.unpause()
            state.switchOnPreviousStatus()
            scene.core?.hud?.removePauseScreen()
        }
    }
    
    /// Disable actions.
    func disable() {
        scene.game?.controller?.manager?.action = nil
        scene.isUserInteractionEnabled = false
    }
    
    /// Enable actions.
    func enable() {
        scene.game?.controller?.setupActions()
        scene.isUserInteractionEnabled = true
    }
}
