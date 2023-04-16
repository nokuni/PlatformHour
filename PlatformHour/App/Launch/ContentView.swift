//
//  ContentView.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 31/01/23.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var scene = GameScene()
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
