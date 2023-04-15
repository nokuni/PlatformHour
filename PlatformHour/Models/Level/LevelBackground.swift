//
//  LevelBackground.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 08/04/23.
//

import Foundation

struct LevelBackground: Codable {
    init(image: String, adjustement: Int) {
        self.image = image
        self.adjustement = adjustement
    }
    
    let image: String
    let adjustement: Int
}
