//
//  Game.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 10/02/23.
//

import SwiftUI
import PlayfulKit

public final class Game: ObservableObject {
    
    init() {
        print("Game Initialized ...")
        fetchSaves()
        createSave()
        world = try? GameWorld.get(currentWorld)
        level = try? GameLevel.get(Int(saves[0].level))
    }
    
    @AppStorage("world") var currentWorld = "Timeless Temple"
    @Published var saves: [SaveEntity] = []
    
    var controller: GameControllerManager?
    
    var world: GameWorld?
    var level: GameLevel?
    
    static let mapMatrix = Matrix(row: 18, column: 50)
    
    let playerCoordinate: Coordinate = Coordinate(x: 13, y: 8)
    
    func createSave() {
        if saves.isEmpty {
            let newSave = SaveEntity(context: SaveManager.shared.container.viewContext)
            newSave.id = UUID()
            registerSave()
            fetchSaves()
        }
    }
    
    func fetchSaves() {
        saves = SaveManager.shared.fetch("SaveEntity")
    }
    
    func registerSave() {
        SaveManager.shared.saveData()
    }
    
    func goToNextLevel() {
        saves[0].level += 1
        registerSave()
        fetchSaves()
    }
}
