//
//  Game.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 10/02/23.
//

import SwiftUI
import PlayfulKit
import Utility_Toolbox

public final class Game: ObservableObject {
    
    public init() {
        loadSave()
    }
    
    @Published var saves: [SaveEntity] = []
    
    static let shared = Game()
    
    public var saveManager = SaveManager(container: PersistenceController.shared.container)
    public var controller: GameControllerManager?
    
    // MARK: - Worlds
    
    public var world: GameWorld?
    
    // MARK: - Levels
    
    public var level: GameLevel?
    public var levelIndex: Int {
        guard let currentLevel = saves.first?.level else { return 0 }
        return Int(currentLevel)
    }
    
    // MARK: - Conversations
    
    public var currentLevelConversation: LevelConversation?
    public var currentConversation: GameConversation?
    
    // MARK: - Cinematics
    
    public var currentLevelCinematic: LevelCinematic?
    public var currentCinematic: GameCinematic?
    
    // MARK: - Save
    
    /// Load the game save.
    public func loadSave() {
        fetchSaves()
        createSave()
        world = GameWorld.get(GameConfiguration.startingWorldID)
        level = GameLevel.get(levelIndex)
    }
    
    /// Create the game save.
    private func createSave() {
        guard saves.isEmpty else { return }
        
        let newSave = SaveEntity(context: saveManager.container.viewContext)
        newSave.id = UUID()
        newSave.level = 0
        save()
        fetchSaves()
    }
    
    /// Fetch the game save.
    private func fetchSaves() {
        if let fetchedSaves: [SaveEntity] = try? saveManager.fetchedObjects(entityName: "SaveEntity") {
            saves = fetchedSaves
        }
    }
    
    /// Save the game progress.
    private func save() { try? saveManager.save() }
    
    /// Save the progress on next game level.
    public func setupNextLevel() {
        guard !saves.isEmpty else { return }
        saves[0].level += 1
        save()
        fetchSaves()
    }
}
