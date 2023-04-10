//
//  LevelBackground.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 08/04/23.
//

import Foundation

public struct LevelBackground: Codable {
    public init(image: String, adjustement: Int) {
        self.image = image
        self.adjustement = adjustement
    }
    
    public let image: String
    public let adjustement: Int
}
