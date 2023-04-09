//
//  SpiralStructurePattern.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 25/03/23.
//

import SpriteKit
import PlayfulKit

public class SpiralStructurePattern {
    
    public init(map: PKMapNode,
                matrix: Matrix,
                coordinate: Coordinate,
                object: PKObjectNode,
                structure: Structure) {
        self.map = map
        self.matrix = matrix
        self.coordinate = coordinate
        self.object = object
        self.structure = structure
    }
    
    public var map: PKMapNode
    public var matrix: Matrix
    public var coordinate: Coordinate
    public var object: PKObjectNode
    public var structure: Structure
    
    public struct CornerPattern {
        public init(topLeft: SKTexture,
                    topRight: SKTexture,
                    bottomRight: SKTexture,
                    bottomLeft: SKTexture) {
            self.topLeft = topLeft
            self.topRight = topRight
            self.bottomRight = bottomRight
            self.bottomLeft = bottomLeft
        }
        
        public let topLeft: SKTexture
        public let topRight: SKTexture
        public let bottomRight: SKTexture
        public let bottomLeft: SKTexture
    }
    
    public struct BorderPattern {
        public init(top: [SKTexture],
                    right: [SKTexture],
                    bottom: [SKTexture],
                    left: [SKTexture]) {
            self.top = top
            self.right = right
            self.bottom = bottom
            self.left = left
        }
        
        public let top: [SKTexture]
        public let right: [SKTexture]
        public let bottom: [SKTexture]
        public let left: [SKTexture]
    }
    
    public struct Pattern {
        public init(cornerPattern: SpiralStructurePattern.CornerPattern,
                    borderPattern: SpiralStructurePattern.BorderPattern) {
            self.cornerPattern = cornerPattern
            self.borderPattern = borderPattern
        }
        
        let cornerPattern: CornerPattern
        let borderPattern: BorderPattern
    }
    
    public struct Structure {
        public init(patterns: [SpiralStructurePattern.Pattern]) {
            self.patterns = patterns
        }
        
        public let patterns: [Pattern]
    }
    
    func create() {
        
        guard isPatternPossible else { return }
        
        var startingIndexValue = 1
        var endingIndexValue = 2
        
        for index in structure.patterns.indices {
            
            addCorners(startingIndexValue: startingIndexValue,
                       textures: (topLeft: structure.patterns[index].cornerPattern.topLeft,
                                  topRight: structure.patterns[index].cornerPattern.topRight,
                                  bottomLeft: structure.patterns[index].cornerPattern.bottomLeft,
                                  bottomRight: structure.patterns[index].cornerPattern.bottomRight))
            
            addBorders(index: index,
                       startingIndexValue: startingIndexValue,
                       endingIndexValue: endingIndexValue,
                       topTextures: structure.patterns[index].borderPattern.top,
                       rightTextures: structure.patterns[index].borderPattern.right,
                       bottomTextures: structure.patterns[index].borderPattern.bottom,
                       leftTextures: structure.patterns[index].borderPattern.left)
            
            startingIndexValue += 1
            endingIndexValue -= 1
        }
    }
    
    private var isPatternPossible: Bool {
        matrix.row > 1 && matrix.column > 1
    }
    
    private func addCorners(startingIndexValue: Int,
                            textures: (topLeft: SKTexture,
                                       topRight: SKTexture,
                                       bottomLeft: SKTexture,
                                       bottomRight: SKTexture)) {
        
        let cornerTopLeftCoordinate = Coordinate(x: coordinate.x + (startingIndexValue - 1), y: coordinate.y + (startingIndexValue - 1))
        let cornerTopRightCoordinate = Coordinate(x: coordinate.x + (startingIndexValue - 1), y: (coordinate.y + matrix.column) - startingIndexValue)
        let cornerBottomLeftCoordinate = Coordinate(x: (coordinate.x + matrix.row) - startingIndexValue, y: coordinate.y + (startingIndexValue - 1))
        let cornerBottomRightCoordinate = Coordinate(x: (coordinate.x + matrix.row) - startingIndexValue, y: (coordinate.y + matrix.column) - startingIndexValue)
        
        map.addObject(object, texture: textures.topLeft, size: map.squareSize, at: cornerTopLeftCoordinate)
        map.addObject(object, texture: textures.topRight, size: map.squareSize, at: cornerTopRightCoordinate)
        map.addObject(object, texture: textures.bottomLeft, size: map.squareSize, at: cornerBottomLeftCoordinate)
        map.addObject(object, texture: textures.bottomRight, size: map.squareSize, at: cornerBottomRightCoordinate)
    }
    
    private func addBorders(index: Int,
                            startingIndexValue: Int,
                            endingIndexValue: Int,
                            topTextures: [SKTexture],
                            rightTextures: [SKTexture],
                            bottomTextures: [SKTexture],
                            leftTextures: [SKTexture]) {
        
        if matrix.column > 2 {
            configureBorders(startingIndexValue: startingIndexValue + index,
                             endingIndexValue: endingIndexValue + index,
                             matrixValue: matrix.column,
                             coordinate: { Coordinate(x: coordinate.x + (startingIndexValue - 1),
                                                      y: (coordinate.y + $0) - (startingIndexValue - 1)) },
                             textures: topTextures)
            configureBorders(startingIndexValue: startingIndexValue + index,
                             endingIndexValue: endingIndexValue + index,
                             matrixValue: matrix.column,
                             coordinate: { Coordinate(x: (coordinate.x + matrix.row) - startingIndexValue,
                                                      y: (coordinate.y + $0) - (startingIndexValue - 1)) },
                             textures: bottomTextures)
        }
        
        if matrix.row > 2 {
            configureBorders(startingIndexValue: startingIndexValue,
                             endingIndexValue: endingIndexValue + (index * 2),
                             matrixValue: matrix.row,
                             coordinate: { Coordinate(x: coordinate.x + $0,
                                                      y: (coordinate.y + matrix.column) - startingIndexValue) },
                             textures: rightTextures)
            
            configureBorders(startingIndexValue: startingIndexValue,
                             endingIndexValue: endingIndexValue + (index * 2),
                             matrixValue: matrix.row,
                             coordinate: { Coordinate(x: coordinate.x + $0,
                                                      y: coordinate.y + (startingIndexValue - 1)) },
                             textures: leftTextures)
        }
    }
    
    private func configureBorders(startingIndexValue: Int,
                                  endingIndexValue: Int,
                                  matrixValue: Int,
                                  coordinate: (Int) -> Coordinate,
                                  textures: [SKTexture]) {
        guard startingIndexValue <= (matrixValue - endingIndexValue) else { return }
        let range = startingIndexValue ... (matrixValue - endingIndexValue)
        let coordinates = range.map { coordinate($0) }
        var textureIndex = 0
        for coordinate in coordinates {
            map.addObject(object,
                          texture: textures[textureIndex],
                          size: map.squareSize,
                          at: coordinate)
            if textureIndex == textures.indices.last { textureIndex = -1 }
            textureIndex += 1
        }
    }
}
