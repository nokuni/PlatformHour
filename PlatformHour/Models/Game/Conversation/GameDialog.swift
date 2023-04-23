//
//  GameDialog.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation

struct GameDialog: Codable {
    
    let character: String?
    var revealNameLine: Int?
    let lines: [String]
    var currentLineIndex: Int = 0
    var isEndOfLine: Bool = false
    
    mutating func moveOnNextLine() {
        if lines.canGoNext(currentLineIndex) {
            currentLineIndex += 1
        } else {
            isEndOfLine = true
        }
    }
    
    func revealFinalName(game: Game?) {
        guard let characterInformations = game?.currentSave?.characterInformations else { return }
        guard let index = characterInformations.firstIndex(where: { $0.keys.first == character }) else { return
        }
        guard let character = character else { return }
        guard characterInformations[index].values.first != character else { return }
        guard let revealNameLine = revealNameLine else { return }
        guard revealNameLine == currentLineIndex else { return }
        game?.currentSave?.characterInformations?[index][character] = character
        game?.updateSaves()
    }
    
    enum CodingKeys: String, CodingKey {
        case character
        case revealNameLine
        case lines
    }
}
