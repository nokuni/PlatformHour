//
//  SpiralStructureConstruct.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 25/03/23.
//

import SpriteKit

final class SpiralStructureConstruct {
    
    init(outline: String,
         firstLayer: String?,
         innerLayer: String?) {
        self.outline = outline
        self.firstLayer = firstLayer
        self.innerLayer = innerLayer
    }
    
    let outline: String
    let firstLayer: String?
    let innerLayer: String?
    
    var outlineCorner: SpiralStructurePattern.CornerPattern? {
        guard let patterns = StructurePattern.get(outline)?.corners else { return nil }
        let atlas = SKTextureAtlas(named: "CavernGrounds")
        let textures = patterns.map { atlas.textureNamed($0) }
        textures.forEach {
            $0.filteringMode = .nearest
            $0.preload { }
        }
        let cornerPattern = SpiralStructurePattern.CornerPattern(
            topLeft: textures[0],
            topRight: textures[1],
            bottomRight: textures[2],
            bottomLeft: textures[3]
        )
        return cornerPattern
    }
    var outlineBorder: SpiralStructurePattern.BorderPattern? {
        guard let patterns = StructurePattern.get(outline)?.borders else { return nil }
        let atlas = SKTextureAtlas(named: "CavernGrounds")
        let textures = patterns.map { atlas.textureNamed($0) }
        textures.forEach {
            $0.filteringMode = .nearest
            $0.preload { }
        }
        let borderPattern = SpiralStructurePattern.BorderPattern(
            top: [textures[0], textures[1], textures[2]],
            right: [textures[3]],
            bottom: [textures[4], textures[5], textures[6]],
            left: [textures[7]]
        )
        return borderPattern
    }
    
    var firstLayerCorner: SpiralStructurePattern.CornerPattern? {
        guard let firstLayer = firstLayer else { return nil }
        guard let patterns = StructurePattern.get(firstLayer)?.corners else { return nil }
        let atlas = SKTextureAtlas(named: "CavernGrounds")
        let textures = patterns.map { atlas.textureNamed($0) }
        textures.forEach {
            $0.filteringMode = .nearest
            $0.preload { }
        }
        let cornerPattern = SpiralStructurePattern.CornerPattern(
            topLeft: textures[0],
            topRight: textures[1],
            bottomRight: textures[2],
            bottomLeft: textures[3]
        )
        return cornerPattern
    }
    var firstLayerBorder: SpiralStructurePattern.BorderPattern? {
        guard let firstLayer = firstLayer else { return nil }
        guard let patterns = StructurePattern.get(firstLayer)?.borders else { return nil }
        let atlas = SKTextureAtlas(named: "CavernGrounds")
        let textures = patterns.map { atlas.textureNamed($0) }
        textures.forEach {
            $0.filteringMode = .nearest
            $0.preload { }
        }
        let borderPattern = SpiralStructurePattern.BorderPattern(
            top: [textures[0], textures[1], textures[2]],
            right: [textures[3]],
            bottom: [textures[4], textures[5], textures[6]],
            left: [textures[7]]
        )
        return borderPattern
    }
    
    var innerLayerCorner: SpiralStructurePattern.CornerPattern? {
        guard let innerLayer = innerLayer else { return nil }
        guard let patterns = StructurePattern.get(innerLayer)?.corners else { return nil }
        let atlas = SKTextureAtlas(named: "CavernGrounds")
        let textures = patterns.map { atlas.textureNamed($0) }
        textures.forEach {
            $0.filteringMode = .nearest
            $0.preload { }
        }
        let cornerPattern = SpiralStructurePattern.CornerPattern(
            topLeft: textures[0],
            topRight: textures[1],
            bottomRight: textures[2],
            bottomLeft: textures[3]
        )
        return cornerPattern
    }
    var innerLayerBorder: SpiralStructurePattern.BorderPattern? {
        guard let innerLayer = innerLayer else { return nil }
        guard let patterns = StructurePattern.get(innerLayer)?.borders else { return nil }
        let atlas = SKTextureAtlas(named: "CavernGrounds")
        let textures = patterns.map { atlas.textureNamed($0) }
        textures.forEach {
            $0.filteringMode = .nearest
            $0.preload { }
        }
        let borderPattern = SpiralStructurePattern.BorderPattern(
            top: [textures[0]],
            right: [textures[1]],
            bottom: [textures[2]],
            left: [textures[3]]
        )
        return borderPattern
    }
    
    var outlinePattern: SpiralStructurePattern.Pattern? {
        guard let outlineCorner = self.outlineCorner else { return nil }
        guard let outlineBorder = self.outlineBorder else { return nil }
        let outlinePattern = SpiralStructurePattern.Pattern(cornerPattern: outlineCorner, borderPattern: outlineBorder)
        return outlinePattern
    }
    
    var firstLayerPattern: SpiralStructurePattern.Pattern? {
        guard let firstLayerCorner = self.firstLayerCorner else { return nil }
        guard let firstLayerBorder = self.firstLayerBorder else { return nil }
        let firstLayerPattern = SpiralStructurePattern.Pattern(cornerPattern: firstLayerCorner, borderPattern: firstLayerBorder)
        return firstLayerPattern
    }
    
    func innerPatterns(structure: LevelStructure) -> [SpiralStructurePattern.Pattern] {
        guard let innerLayerCorner = self.innerLayerCorner else { return [] }
        guard let innerLayerBorder = self.innerLayerBorder else { return [] }
        
        let innerLayers: [(SpiralStructurePattern.CornerPattern, SpiralStructurePattern.BorderPattern)] =
        Array(repeating: (innerLayerCorner, innerLayerBorder),
              count: structure.innerLayerAmount ?? 0)
        
        let innerPatterns = innerLayers.map {
            SpiralStructurePattern.Pattern(cornerPattern: $0.0, borderPattern: $0.1)
        }
        return innerPatterns
    }
}
