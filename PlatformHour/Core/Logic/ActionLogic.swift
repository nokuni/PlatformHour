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
    
    public enum Direction: String, CaseIterable {
        case none
        case up
        case down
        case right
        case left
    }
    
    public var scene: GameScene
    
    public var timer: Timer?
    public var direction: Direction = .none
    public var movementSpeed: Int = 0
    
    public var isAnimating: Bool {
        guard let player = scene.player else { return false }
        return player.node.hasActions()
    }
    public var isAttacking: Bool {
        scene.isExistingChildNode(named: GameConfiguration.nodeKey.playerProjectile)
    }
    public var canAct: Bool {
        scene.isUserInteractionEnabled
    }
    //private var dialogIndex = 0
    public var isLongPressingDPad: Bool = false
    
    // MARK: - Underlying Actions/Animations
    private func addAction(_ action: Player.SequenceAction) {
        guard let player = scene.player else { return }
        guard player.actions.count < player.currentRoll.rawValue else { return }
        player.actions.append(action)
        let actionElement = SKSpriteNode(imageNamed: action.icon)
        actionElement.texture?.filteringMode = .nearest
        actionElement.size = GameConfiguration.sceneConfiguration.tileSize * 0.6
        scene.core?.hud?.actionSquares[safe: player.actions.count - 1]?.addChildSafely(actionElement)
        scene.core?.logic?.resolveSequenceOfActions()
    }
    
    public func move(on direction: Direction, by movementSpeed: Int) {
        guard let player = scene.player else { return }
        guard !isAnimating else { return }
        guard !player.state.isJumping else { return }
        guard canAct else { return }
        
        isLongPressingDPad = true
        scene.core?.event?.dismissButtonPopUp()
        self.direction = direction
        changeOrientation(direction: self.direction)
        self.movementSpeed = movementSpeed
        moveAnimation(by: self.movementSpeed)
        scene.player?.advanceRoll()
        scene.player?.run()
    }
    
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
    
    private func moveAnimation(by amount: Int) {
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
    private func changeOrientation(direction: Direction) {
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
    
    // MARK: - Directional Actions
    
    /// Trigger right pad actions.
    public func rightPadAction() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            moveRight()
        case .inAction:
            addAction(.moveRight)
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger left pad actions.
    public func leftPadAction() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            moveLeft()
        case .inAction:
            addAction(.moveLeft)
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger up pad actions.
    public func upPadAction() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            break
        case .inAction:
            addAction(.moveUp)
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    /// Trigger down pad actions.
    public func downPadAction() {
        guard let state = scene.core?.state else { return }
        switch state.status {
        case .inDefault:
            break
        case .inAction:
            addAction(.moveDown)
        case .inConversation:
            break
        case .inCinematic:
            break
        case .inPause:
            break
        }
    }
    
    private func moveRight() {
        guard let player = scene.player else { return }
        guard !player.state.isJumping else { return }
        guard !isAnimating else { return }
        guard canAct else { return }
        
        let movementSpeed = GameConfiguration.playerConfiguration.movementSpeed
        
        move(on: .right, by: movementSpeed)
    }
    private func moveLeft() {
        guard let player = scene.player else { return }
        guard !player.state.isJumping else { return }
        guard !isAnimating else { return }
        guard canAct else { return }
        
        let movementSpeed = -GameConfiguration.playerConfiguration.movementSpeed
        
        move(on: .left, by: movementSpeed)
    }
    
    // MARK: - Button Actions
    
    /// Trigger button A actions.
    public func actionA() {
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
    public func actionB() {
        
    }
    
    /// Trigger button X actions.
    public func actionX() {
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
    public func actionY() {
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

    public func releaseDPad() {
        isLongPressingDPad = false
    }
    
    private func jump() {
        guard let player = scene.player else { return }
        guard !player.state.isJumping else { return }
        guard player.interactionStatus == .none else { return }
        guard !isAnimating else { return }
        
        let action = jumpAction(player: player)
        
        scene.game?.controller?.action.disable()
        player.state.isJumping = true
        player.node.run(action)
    }
    
    private func attack() {
        guard !isAttacking else { return }
        guard !isAnimating else { return }
        guard canAct else { return }
        
        if let projectileNode = scene.core?.content?.projectileNode {
            scene.addChild(projectileNode)
            throwProjectile(projectileNode)
        }
    }
    
    private func interact() {
        guard let player = scene.player else { return }
        guard canAct else { return }
        
        switch player.interactionStatus {
        case .none:
            ()
        case .onExit:
            scene.core?.event?.loadNextLevel()
        }
    }
    
    // MARK: - Miscellaneous
    
    public func pause() {
        guard let state = scene.core?.state else { return }
        scene.core?.content?.pause()
        state.switchOn(newStatus: .inPause)
        scene.core?.hud?.createPauseScreen()
    }
    
    public func unPause() {
        guard let state = scene.core?.state else { return }
        if state.status == .inPause {
            scene.core?.content?.unpause()
            state.switchOnPreviousStatus()
            scene.core?.hud?.removePauseScreen()
        }
    }
    
    public func disable() {
        scene.game?.controller?.manager?.action = nil
        scene.isUserInteractionEnabled = false
    }
    
    public func enable() {
        scene.game?.controller?.setupActions()
        scene.isUserInteractionEnabled = true
    }
    
    // MARK: - Animations
    
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
            self.scene.core?.animation?.addGravityEffect(scene: self.scene, node: player.node)
            self.scene.core?.state.switchOn(newStatus: .inAction)
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
            if self.isLongPressingDPad {
                self.move(on: self.direction, by: self.movementSpeed)
            }
        }
        
        return action
    }
}
