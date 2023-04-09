//
//  SpiralStructureConstruct.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 25/03/23.
//

import SpriteKit

public class SpiralStructureConstruct {
    
    public init(outline: String,
         firstLayer: String?,
         innerLayer: String?) {
        self.outline = outline
        self.firstLayer = firstLayer
        self.innerLayer = innerLayer
    }
    
    public let outline: String
    public let firstLayer: String?
    public let innerLayer: String?
    
    public var outlineCorner: SpiralStructurePattern.CornerPattern? {
        guard let patterns = StructurePattern.get(outline)?.corners else { return nil }
        let cornerPattern = SpiralStructurePattern.CornerPattern(
            topLeft: SKTexture.filtered(patterns[0], by: .nearest),
            topRight: SKTexture.filtered(patterns[1], by: .nearest),
            bottomRight: SKTexture.filtered(patterns[2], by: .nearest),
            bottomLeft: SKTexture.filtered(patterns[3], by: .nearest)
        )
        return cornerPattern
    }
    public var outlineBorder: SpiralStructurePattern.BorderPattern? {
        guard let patterns = StructurePattern.get(outline)?.borders else { return nil }
        let borderPattern = SpiralStructurePattern.BorderPattern(
            top: [
                SKTexture.filtered(patterns[0], by: .nearest),
              SKTexture.filtered(patterns[1], by: .nearest),
              SKTexture.filtered(patterns[2], by: .nearest)
            ],
            right: [
              SKTexture.filtered(patterns[3], by: .nearest)
            ],
            bottom: [
              SKTexture.filtered(patterns[4], by: .nearest),
              SKTexture.filtered(patterns[5], by: .nearest),
              SKTexture.filtered(patterns[6], by: .nearest)
            ],
            left: [
              SKTexture.filtered(patterns[7], by: .nearest)
            ]
        )
        return borderPattern
    }
    
    public var firstLayerCorner: SpiralStructurePattern.CornerPattern? {
        guard let firstLayer = firstLayer else { return nil }
        guard let patterns = StructurePattern.get(firstLayer)?.corners else { return nil }
        let cornerPattern = SpiralStructurePattern.CornerPattern(
            topLeft: SKTexture.filtered(patterns[0], by: .nearest),
            topRight: SKTexture.filtered(patterns[1], by: .nearest),
            bottomRight: SKTexture.filtered(patterns[2], by: .nearest),
            bottomLeft: SKTexture.filtered(patterns[3], by: .nearest)
        )
        return cornerPattern
    }
    public var firstLayerBorder: SpiralStructurePattern.BorderPattern? {
        guard let firstLayer = firstLayer else { return nil }
        guard let patterns = StructurePattern.get(firstLayer)?.borders else { return nil }
        let borderPattern = SpiralStructurePattern.BorderPattern(
            top: [
                SKTexture.filtered(patterns[0], by: .nearest),
              SKTexture.filtered(patterns[1], by: .nearest),
              SKTexture.filtered(patterns[2], by: .nearest)
            ],
            right: [
              SKTexture.filtered(patterns[3], by: .nearest)
            ],
            bottom: [
              SKTexture.filtered(patterns[4], by: .nearest),
              SKTexture.filtered(patterns[5], by: .nearest),
              SKTexture.filtered(patterns[6], by: .nearest)
            ],
            left: [
              SKTexture.filtered(patterns[7], by: .nearest)
            ]
        )
        return borderPattern
    }
    
    public var innerLayerCorner: SpiralStructurePattern.CornerPattern? {
        guard let innerLayer = innerLayer else { return nil }
        guard let patterns = StructurePattern.get(innerLayer)?.corners else { return nil }
        let cornerPattern = SpiralStructurePattern.CornerPattern(
            topLeft: SKTexture.filtered(patterns[0], by: .nearest),
            topRight: SKTexture.filtered(patterns[1], by: .nearest),
            bottomRight: SKTexture.filtered(patterns[2], by: .nearest),
            bottomLeft: SKTexture.filtered(patterns[3], by: .nearest)
        )
        return cornerPattern
    }
    public var innerLayerBorder: SpiralStructurePattern.BorderPattern? {
        guard let innerLayer = innerLayer else { return nil }
        guard let patterns = StructurePattern.get(innerLayer)?.borders else { return nil }
        let borderPattern = SpiralStructurePattern.BorderPattern(
            top: [
                SKTexture.filtered(patterns[0], by: .nearest)
            ],
            right: [
              SKTexture.filtered(patterns[1], by: .nearest)
            ],
            bottom: [
              SKTexture.filtered(patterns[2], by: .nearest)
            ],
            left: [
              SKTexture.filtered(patterns[3], by: .nearest)
            ]
        )
        return borderPattern
    }
    
    public var outlinePattern: SpiralStructurePattern.Pattern? {
        guard let outlineCorner = self.outlineCorner else { return nil }
        guard let outlineBorder = self.outlineBorder else { return nil }
        let outlinePattern = SpiralStructurePattern.Pattern(cornerPattern: outlineCorner, borderPattern: outlineBorder)
        return outlinePattern
    }
    
    public var firstLayerPattern: SpiralStructurePattern.Pattern? {
        guard let firstLayerCorner = self.firstLayerCorner else { return nil }
        guard let firstLayerBorder = self.firstLayerBorder else { return nil }
        let firstLayerPattern = SpiralStructurePattern.Pattern(cornerPattern: firstLayerCorner, borderPattern: firstLayerBorder)
        return firstLayerPattern
    }
    
    public func innerPatterns(structure: LevelStructure) -> [SpiralStructurePattern.Pattern] {
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
