//
//  LevelConversation.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation

struct LevelConversation: Codable {
    let conversation: String
    let triggerCoordinate: String?
    var isAvailable: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case conversation
        case triggerCoordinate
    }
}
