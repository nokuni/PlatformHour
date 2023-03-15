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
        print("Game Initialized ...")
        loadSaves()
        createSave()
        world = GameWorld.get(currentWorld)
        level = GameLevel.get(Int(saves[0].level))
    }
    
    @AppStorage("world") var currentWorld = "Timeless Temple"
    @Published var saves: [SaveEntity] = []
    
    var saveManager = SaveManager(container: PersistenceController.shared.container)
    var controller: GameControllerManager?
    var world: GameWorld?
    var level: GameLevel?
    
    static let mapMatrix = Matrix(row: 18, column: 50)
    
    func createSave() {
        if saves.isEmpty {
            let newSave = SaveEntity(context: saveManager.container.viewContext)
            newSave.id = UUID()
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
    
    func goToNextLevel() {
        saves[0].level += 1
        save()
        loadSaves()
    }
}
