//
//  Game.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 10/02/23.
//

import SwiftUI
import PlayfulKit
import Utility_Toolbox

final class Game: ObservableObject {
    
    init() {
        loadSave()
    }
    
    @Published var saves: [SaveEntity] = []
    
    static let shared = Game()
    
    var saveManager = SaveManager(container: PersistenceController.shared.container)
    var controller: GameControllerManager?
    
    // MARK: - Worlds
    
    var world: GameWorld?
    
    // MARK: - Levels
    
    var level: GameLevel?
    var levelIndex: Int {
        guard let currentLevel = saves.first?.level else { return 0 }
        return Int(currentLevel)
    }
    
    // MARK: - Conversations
    
    var currentLevelConversation: LevelConversation?
    var currentConversation: GameConversation?
    
    // MARK: - Cinematics
    
    var currentLevelCinematic: LevelCinematic?
    var currentCinematic: GameCinematic?
    
    // MARK: - Save
    
    /// Load the game save.
    func loadSave() {
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
    func setupNextLevel() {
        guard !saves.isEmpty else { return }
        saves[0].level += 1
        save()
        fetchSaves()
    }
}
