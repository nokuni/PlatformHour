//
//  LevelConversation.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 07/04/23.
//

import Foundation

public struct LevelConversation: Codable {
    public init(conversation: String,
                triggerCoordinate: String,
                isAvailable: Bool = true) {
        self.conversation = conversation
        self.triggerCoordinate = triggerCoordinate
        self.isAvailable = isAvailable
    }
    
    public let conversation: String
    public let triggerCoordinate: String?
    public var isAvailable: Bool = true
    
    enum CodingKeys: String, CodingKey {
        case conversation
        case triggerCoordinate
    }
}
