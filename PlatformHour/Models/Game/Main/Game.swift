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
    
    init() {
        loadSave()
    }
    
    //    @AppStorage("world") var currentWorld = "Timeless Temple"
    @Published var saves: [SaveEntity] = []
    
    static let shared = Game()
    
    var saveManager = SaveManager(container: PersistenceController.shared.container)
    var controller: GameControllerManager?
    
    var world: GameWorld?
    var level: GameLevel?
    
    var currentLevelDialog: LevelDialog?
    var currentDialog: GameDialog?
    
    var levelIndex: Int {
        guard let currentLevel = saves.first?.level else { return 0 }
        return Int(currentLevel)
    }
    
    func loadSave() {
        loadSaves()
        createSave()
        world = GameWorld.get(0)
        level = GameLevel.get(levelIndex)
    }
    
    func createSave() {
        if saves.isEmpty {
            let newSave = SaveEntity(context: saveManager.container.viewContext)
            newSave.id = UUID()
            newSave.level = 0
            save()
            loadSaves()
        }
    }
    
    func loadSaves() {
        if let fetchedSaves: [SaveEntity] = try? saveManager.fetchedObjects(entityName: "SaveEntity") {
            saves = fetchedSaves
        }
    }
    
    func save() {
        try? saveManager.save()
    }
    
    func setupNextLevel() {
        saves[0].level += 1
        save()
        loadSaves()
    }
}
