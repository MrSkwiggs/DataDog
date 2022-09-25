//
//  FixedSizeCollection.swift
//  
//
//  Created by Dorian Grolaux on 25/09/2022.
//

import Foundation

public struct FixedSizeCollection<Element> {
    
    private var elements: [Element]
    public var maxCount: Int
    
    public init(elements: [Element] = [], maxCount: Int) {
        self.elements = elements
        self.maxCount = maxCount
    }
    
    public init(repeating element: Element, count: Int) {
        self.elements = .init(repeating: element, count: count)
        self.maxCount = count
    }
}

extension FixedSizeCollection: Collection, ExpressibleByArrayLiteral {
    
    public typealias Index = Int
    public typealias Element = Element
    
    public init(arrayLiteral elements: Element...) {
        self.elements = elements
        maxCount = elements.count
    }
    
    public var startIndex: Index { return elements.startIndex }
    public var endIndex: Index { return elements.endIndex }
    
    public subscript(index: Index) -> Iterator.Element {
        get { return elements[index] }
    }
    
    public func index(after i: Index) -> Index {
        return elements.index(after: i)
    }
    
    @discardableResult
    public mutating func append(_ newElement: Element) -> Element? {
        elements.append(newElement)
        return removeExtraElements().first
    }
    
    @discardableResult
    public mutating func append<C>(contentsOf newElements: C) -> [Element] where C : Collection, FixedSizeCollection.Element == C.Element {
        elements.append(contentsOf: newElements)
        return removeExtraElements()
    }
    
    @discardableResult
    public mutating func insert(_ newElement: Element, at i: Int) -> Element? {
        elements.insert(newElement, at: i)
        return removeExtraElements().first
    }
    
    @discardableResult
    public mutating func insert<C>(contentsOf newElements: C, at i: Int) -> [Element] where C : Collection, FixedSizeCollection.Element == C.Element {
        elements.insert(contentsOf: newElements, at: i)
        return removeExtraElements()
    }
    
    private mutating func removeExtraElements() -> [Element] {
        guard elements.count > maxCount else { return [] }
        
        var poppedElements: [Element] = []
        poppedElements.append(contentsOf: elements[maxCount..<elements.count])
        elements.removeFirst(elements.count - maxCount)
        return poppedElements
    }
}
