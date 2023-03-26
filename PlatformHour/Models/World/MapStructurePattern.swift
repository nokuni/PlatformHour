//
//  MapStructurePattern.swift
//  PlatformHour
//
//  Created by Maertens Yann-Christophe on 25/03/23.
//

import PlayfulKit

public class MapStructurePattern {
    
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
                map.addObject(object,
                              image: exception.image,
                              filteringMode: .nearest,
                              logic: LogicBody(),
                              drops: [],
                              animations: [],
                              at: coordinate)
            } else {
                map.addObject(object,
                              image: pattern.images[pattern.currentIndex],
                              filteringMode: .nearest,
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
}
