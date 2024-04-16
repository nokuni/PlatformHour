//
//  Game.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 10/02/23.
//

import SwiftUI
import PlayfulKit
import UtilityToolbox

final class Game: ObservableObject {
    
    init() {
        loadSave()
    }
    
    @Published var saves: [SaveEntity] = []
    
    static let shared = Game()
    
    var saveManager = SaveManager(container: PersistenceController.shared.container)
    var controller: GameControllerManager?
    
    var language = LanguageManager.shared.language
    
    // MARK: - Worlds
    
    var world: GameWorld?
    
    // MARK: - Levels
    
    var level: GameLevel?
    var levelIndex: Int {
        guard let currentLevel = saves.first?.level else { return 0 }
        return Int(currentLevel)
    }
    
    // MARK: - Observed objects
    
    var currentInteractiveObject: PKObjectNode?
    
    // MARK: - Conversations
    
    var currentLevelConversation: LevelConversation?
    var currentConversation: GameConversation?
    var isConversationAvailable: Bool {
        guard let passedConversations = saves[saveIndex].passedConversations else { return false }
        guard let level = level else { return false }
        let conversationNames = level.conversations.map { $0.name }
        return !passedConversations.contains(conversationNames)
    }
    
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
        newSave.maxEnergy = 100
        newSave.powers = ["Movement"]
        newSave.passedCinematics = [""]
        newSave.passedConversations = [""]
        newSave.characterInformations = [
            ["Neo": "???"],
            ["Bloopy": "???"]
        ]
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

// MARK: - Player

extension Game {
    
    /// Returns max energy of the player.
    var playerMaxEnergy: Int {
        guard let maxEnergySave = currentSave?.maxEnergy else { return 100 }
        let maxEnergy = Int(maxEnergySave)
        return maxEnergy
    }
    
    /// Increases max energy by a specific amount.
    func increaseMaxEnergy(amount: Int) {
        currentSave?.maxEnergy += Int32(amount)
        updateSaves()
    }
    
    /// Unlock a new power for the player depending on his max energy.
    func unlockPower() {
        switch true {
        case playerMaxEnergy == 125:
            currentSave?.powers?.append(PlayerPower.levitate.rawValue)
        default:
            print("No power unlocked")
        }
        
        updateSaves()
    }
    
    /// Returns the image frames of the energy HUD.
    func energyFrames(energy: Int) -> [String] {
        var image = ""
        
        switch true {
        case energy > playerMaxEnergy.percentageValue(percentage: 90):
            image = "energyCharged5"
        case energy > playerMaxEnergy.percentageValue(percentage: 70):
            image = "energyCharged4"
        case energy > playerMaxEnergy.percentageValue(percentage: 50):
            image = "energyCharged3"
        case energy > playerMaxEnergy.percentageValue(percentage: 30):
            image = "energyCharged2"
        case energy > playerMaxEnergy.percentageValue(percentage: 10):
            image = "energyCharged1"
        default:
            image = "energyCharged0"
        }
        
        return ["\(image)0", "\(image)1", "\(image)2", "\(image)3"]
    }
    
    /// Check if the player has unlocked a power.
    func hasPlayerUnlock(power: PlayerPower) -> Bool {
        guard let powers = currentSave?.powers else { return false }
        return powers.contains(power.rawValue)
    }
}
