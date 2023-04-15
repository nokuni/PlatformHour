//
//  LevelConversation.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation

struct LevelConversation: Codable {
    init(conversation: String,
                triggerCoordinate: String,
                isAvailable: Bool = true) {
        self.conversation = conversation
        self.triggerCoordinate = triggerCoordinate
        self.isAvailable = isAvailable
    }
    
    let conversation: String
    let triggerCoordinate: String?
    var isAvailable: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case conversation
        case triggerCoordinate
    }
}
