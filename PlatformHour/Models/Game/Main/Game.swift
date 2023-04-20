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
    var isCinematicAvailable: Bool {
        guard let passedCinematics = saves[saveIndex].passedCinematics else { return false }
        guard let level = level else { return false }
        let cinematicNames = level.cinematics.map { $0.name }
        return !passedCinematics.contains(cinematicNames)
    }
    
    var hasTitleBeenDisplayed: Bool = false
    
    // MARK: - Save
    
    @AppStorage("Save index") var saveIndex: Int = 0
    
    /// Get the current save.
    var currentSave: SaveEntity? {
        saves.first
    }
    
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
        newSave.passedCinematics = [""]
        updateSaves()
    }
    
    /// Fetch the game save.
    private func fetchSaves() {
        if let fetchedSaves: [SaveEntity] = try? saveManager.fetchedObjects(entityName: "SaveEntity") {
            saves = fetchedSaves
        }
    }
    
    /// Update the current game save.
    func updateSaves() {
        save()
        fetchSaves()
    }
    
    /// Save the game progress.
    private func save() { try? saveManager.save() }
    
    /// Save the progress on next game level.
    func setupNextLevel() {
        guard !saves.isEmpty else { return }
        saves[saveIndex].level += 1
        save()
        fetchSaves()
    }
}
