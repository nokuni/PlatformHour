//
//  MapStructurePattern.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 25/03/23.
//

import SpriteKit
import PlayfulKit

/*
 X X X X X
 X X X X X
 X X X X X
 X X X X X X X
 X X X X X X X X X X
 
 // first step: Create the structure as a rectangle following the pattern
 // second step: Exclude some parts of the structure if specified.
 // third step: Apply the layer pattern.
 */

/*public class MapStructurePattern {
 
 public init(map: PKMapNode,
 matrix: Matrix,
 coordinate: Coordinate,
 object: PKObjectNode,
 simple: SimplePattern?) {
 self.map = map
 self.matrix = matrix
 self.coordinate = coordinate
 self.object = object
 self.simple = simple
 }
 
 public var map: PKMapNode
 public var matrix: Matrix
 public var coordinate: Coordinate
 public var object: PKObjectNode
 
 public var simple: SimplePattern?
 
 private struct Pattern {
 internal init(images: [String], exceptions: [MapStructurePattern.ExceptionImage] = [], currentIndex: Int = 0) {
 self.images = images
 self.exceptions = exceptions
 self.currentIndex = currentIndex
 }
 
 let images: [String]
 var exceptions: [ExceptionImage] = []
 var currentIndex: Int = 0
 
 mutating func advance() {
 if currentIndex < (images.count - 1) {
 currentIndex += 1
 } else {
 currentIndex = 0
 }
 }
 }
 private struct ExceptionImage {
 internal init(image: String, coordinate: Coordinate) {
 self.image = image
 self.coordinate = coordinate
 }
 
 let image: String
 var coordinate: Coordinate
 }
 public struct SimplePattern {
 let firstRow: (pattern: [String],
 extremities: (left: String, right: String))
 let secondRow: (pattern: [String],
 extremities: (left: String, right: String))
 let repeatedRow: (pattern: [String],
 extremities: (left: String, right: String),
 periphery: (left: String, right: String))
 let beforeLastRow: (pattern: [String],
 extremities: (left: String, right: String))
 let lastRow: (pattern: [String],
 extremities: (left: String, right: String))
 }
 
 public func create() {
 var patterns: [Pattern] = []
 patterns = simplePatterns
 
 guard !patterns.isEmpty else { return }
 guard patterns.count == matrix.row else { return }
 guard patternCoordinates.count == matrix.row else { return }
 guard patterns.count == patternCoordinates.count else { return }
 
 for index in 0 ..< matrix.row {
 applyPattern(pattern: &patterns[index], object: object, coordinates: patternCoordinates[index])
 }
 }
 
 private func applyPattern(pattern: inout Pattern,
 object: PKObjectNode,
 coordinates: [Coordinate]) {
 for coordinate in coordinates {
 if let exception = pattern.exceptions.first(where: {
 $0.coordinate == coordinate
 }) {
 let texture = SKTexture(imageNamed: exception.image)
 texture.filteringMode = .nearest
 map.addObject(object,
 texture: texture,
 size: map.squareSize,
 logic: LogicBody(),
 drops: [],
 animations: [],
 at: coordinate)
 } else {
 let texture = SKTexture(imageNamed: pattern.images[pattern.currentIndex])
 texture.filteringMode = .nearest
 map.addObject(object,
 texture: texture,
 size: map.squareSize,
 logic: LogicBody(),
 drops: [],
 animations: [], at: coordinate)
 }
 pattern.advance()
 }
 }
 
 private var patternCoordinates: [[Coordinate]] {
 let columnIndices = coordinate.y ..< coordinate.y + (matrix.column)
 var coordinateArrays: [[Coordinate]] = []
 for row in coordinate.x ..< (matrix.row + coordinate.x) {
 let coordinates = columnIndices.map {
 Coordinate(x: row, y: $0)
 }
 coordinateArrays.append(coordinates)
 }
 return coordinateArrays
 }
 
 private var simplePatterns: [Pattern] {
 guard let simple = simple else { return [] }
 let pattern = Pattern(images: simple.repeatedRow.pattern,
 exceptions: [
 ExceptionImage(image: simple.repeatedRow.extremities.left,
 coordinate: Coordinate(x: coordinate.x + 2,
 y: coordinate.y)
 ),
 ExceptionImage(image: simple.repeatedRow.periphery.left,
 coordinate: Coordinate(x: coordinate.x + 2,
 y: coordinate.y + 1)
 ),
 ExceptionImage(image: simple.repeatedRow.extremities.right,
 coordinate: Coordinate(x: coordinate.x + 2,
 y: coordinate.y + (matrix.column - 1))
 ),
 ExceptionImage(image: simple.repeatedRow.periphery.right,
 coordinate: Coordinate(x: coordinate.x + 2,
 y: coordinate.y + (matrix.column - 2))
 ),
 ])
 var repeatedPatterns: [Pattern] = []
 
 for index in 0..<(matrix.row - 4) {
 var pattern = pattern
 
 var coordinates = pattern.exceptions.map { $0.coordinate }
 
 coordinates.indices.forEach {
 coordinates[$0].x += index
 }
 
 pattern.exceptions.indices.forEach {
 pattern.exceptions[$0].coordinate = coordinates[$0]
 }
 
 repeatedPatterns.append(pattern)
 }
 
 var patterns: [Pattern] = []
 
 patterns.append(contentsOf: [
 Pattern(images: simple.firstRow.pattern,
 exceptions: [
 ExceptionImage(image: simple.firstRow.extremities.left,
 coordinate: coordinate),
 ExceptionImage(image: simple.firstRow.extremities.right,
 coordinate: Coordinate(x: coordinate.x,
 y: matrix.column - 1))
 ]),
 Pattern(images: simple.secondRow.pattern,
 exceptions: [
 ExceptionImage(image: simple.secondRow.extremities.left,
 coordinate: Coordinate(x: coordinate.x + 1,
 y: coordinate.y)),
 ExceptionImage(image: simple.secondRow.extremities.right,
 coordinate: Coordinate(x: coordinate.x + 1,
 y: coordinate.y + (matrix.column - 1)))
 ]),
 ])
 
 patterns.append(contentsOf: repeatedPatterns)
 
 patterns.append(contentsOf: [
 Pattern(images: simple.beforeLastRow.pattern,
 exceptions: [
 ExceptionImage(image: simple.beforeLastRow.extremities.left,
 coordinate: Coordinate(x: coordinate.x + (matrix.row - 2), y: coordinate.y)),
 ExceptionImage(image: simple.beforeLastRow.extremities.right,
 coordinate: Coordinate(x: coordinate.x + (matrix.row - 2), y: matrix.column - 1))
 ]),
 Pattern(images: simple.lastRow.pattern,
 exceptions: [
 ExceptionImage(image: simple.lastRow.extremities.left,
 coordinate: Coordinate(x: coordinate.x + (matrix.row - 1), y: coordinate.y)),
 ExceptionImage(image: simple.lastRow.extremities.right,
 coordinate: Coordinate(x: coordinate.x + (matrix.row - 1), y: matrix.column - 1))
 ]),
 ])
 
 return patterns
 }
 }*/

class TestPattern {
    
    public init(map: PKMapNode,
                matrix: Matrix,
                coordinate: Coordinate,
                object: PKObjectNode,
                structure: MapStructure) {
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
    public var structure: MapStructure
    
    func create() {
        map.addObject(object,
                      structure: structure,
                      size: map.squareSize,
                      startingCoordinate: coordinate,
                      matrix: matrix)
    }
    
    private var cornerTopLeftCoordinate: Coordinate {
        coordinate
    }
    private var cornerTopRightCoordinate: Coordinate {
        Coordinate(x: coordinate.x, y: (coordinate.y + matrix.column) - 1)
    }
    private var cornerBottomLeftCoordinate: Coordinate {
        Coordinate(x: (coordinate.x + matrix.row) - 1, y: coordinate.y)
    }
    private var cornerBottomRightCoordinate: Coordinate {
        Coordinate(x: (coordinate.x + matrix.row) - 1, y: (coordinate.y + matrix.column) - 1)
    }
    
    private func addCorners(textures: (topLeft: SKTexture,
                                       topRight: SKTexture,
                                       bottomLeft: SKTexture,
                                       bottomRight: SKTexture)) {
        map.addObject(object, texture: textures.topLeft, size: map.squareSize, at: cornerTopLeftCoordinate)
        map.addObject(object, texture: textures.topRight, size: map.squareSize, at: cornerTopRightCoordinate)
        map.addObject(object, texture: textures.bottomLeft, size: map.squareSize, at: cornerBottomLeftCoordinate)
        map.addObject(object, texture: textures.bottomRight, size: map.squareSize, at: cornerBottomRightCoordinate)
    }
    private func addBorders(topTextures: [SKTexture],
                            rightTextures: [SKTexture],
                            bottomTextures: [SKTexture],
                            leftTextures: [SKTexture]) {
        
        let topRange = 1 ... matrix.column - 2
        let topCoordinates = topRange.map {
            Coordinate(x: coordinate.x, y: coordinate.y + $0)
        }
        var topTextureIndex = 0
        for topCoordinate in topCoordinates {
            map.addObject(object,
                          texture: topTextures[topTextureIndex],
                          size: map.squareSize,
                          at: topCoordinate)
            if topTextureIndex == topTextures.indices.last { topTextureIndex = 0 }
        }
        
        let rightRange = 1 ... matrix.row - 2
        let rightCoordinates = rightRange.map {
            Coordinate(x: coordinate.x + $0, y: (coordinate.y + matrix.column) - 1)
        }
        var rightTextureIndex = 0
        for rightCoordinate in rightCoordinates {
            map.addObject(object,
                          texture: rightTextures[rightTextureIndex],
                          size: map.squareSize,
                          at: rightCoordinate)
            if rightTextureIndex == rightTextures.indices.last { rightTextureIndex = 0 }
        }
        
        let bottomRange = 1 ... matrix.column - 2
        let bottomCoordinates = bottomRange.map {
            Coordinate(x: (coordinate.x + matrix.row) - 1, y: coordinate.y + $0)
        }
        var bottomTextureIndex = 0
        for bottomCoordinate in bottomCoordinates {
            map.addObject(object,
                          texture: bottomTextures[bottomTextureIndex],
                          size: map.squareSize,
                          at: bottomCoordinate)
            if bottomTextureIndex == bottomTextures.indices.last { bottomTextureIndex = 0 }
        }
        
        let leftRange = 1 ... matrix.row - 2
        let leftCoordinates = leftRange.map {
            Coordinate(x: coordinate.x + $0, y: coordinate.y)
        }
        var leftTextureIndex = 0
        for leftCoordinate in leftCoordinates {
            map.addObject(object,
                          texture: leftTextures[leftTextureIndex],
                          size: map.squareSize,
                          at: leftCoordinate)
            if leftTextureIndex == leftTextures.indices.last { leftTextureIndex = 0 }
        }
    }
    private func addInternal() {
        
    }
    
    func applyInternalLayers() {
        
    }
}

/*
 A E E E E E E E E B
 H X X X X X X X X F
 H X X X X X X X X F
 H X X X X X X X X F
 C G G G G G G G G D
 */
