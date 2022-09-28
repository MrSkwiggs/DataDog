//
//  CommonTests.swift
//  
//
//  Created by Dorian Grolaux on 28/09/2022.
//

import XCTest
@testable import Watcher

final class CommonTests: XCTestCase {

    func testRangeValueClamping() {
        let range = Float(0)...Float(1)
        XCTAssertEqual(range.clamping(0.5), 0.5)
        XCTAssertEqual(range.clamping(2), 1.0)
        XCTAssertEqual(range.clamping(-0.2), 0.0)
    }
    
    func testFixedSizeCollectionInstantiation() {
        let array: [Float] = [0, 0, 0, 0, 0]
        let collection1: FixedSizeCollection = [Float(0), 0, 0, 0, 0]
        let collection2 = FixedSizeCollection(repeating: Float(0), count: 5)
        let collection3 = FixedSizeCollection(elements: array, maxCount: 5)
        
        [collection1, collection2, collection3]
            .forEach { collection in
                XCTAssertEqual(Array(collection), array)
                XCTAssertEqual(collection.maxCount, 5)
            }
    }
    
    func testFixedSizeCollectionMutation() {
        var collection: FixedSizeCollection = [0, 1, 2, 3, 4, 5]
        
        XCTAssertEqual(collection.maxCount, 6)
        
        collection.append(6)
        XCTAssertEqual(collection, [1, 2, 3, 4, 5, 6])
        
        collection.append(contentsOf: [1, 2, 1, 2])
        XCTAssertEqual(collection, [5, 6, 1, 2, 1, 2])
    }
    
    func testFloatExpressedAsPercentage() {
        let zeroToOneRange = Float(0.0)...Float(1.0)
    
        XCTAssertEqual(Float(0.5), Float(0.5).expressedAsPercentage(ofMinValue: zeroToOneRange.lowerBound, maxValue: zeroToOneRange.upperBound))
        XCTAssertEqual(Float(0.0), Float(0.0).expressedAsPercentage(ofMinValue: zeroToOneRange.lowerBound, maxValue: zeroToOneRange.upperBound))
        XCTAssertEqual(Float(1.0), Float(1.0).expressedAsPercentage(ofMinValue: zeroToOneRange.lowerBound, maxValue: zeroToOneRange.upperBound))
        XCTAssertEqual(Float(-2.0), Float(-2.0).expressedAsPercentage(ofMinValue: zeroToOneRange.lowerBound, maxValue: zeroToOneRange.upperBound))
        XCTAssertEqual(Float(3.0), Float(3.0).expressedAsPercentage(ofMinValue: zeroToOneRange.lowerBound, maxValue: zeroToOneRange.upperBound))
        
        let minusTenToTenRange = Float(-10)...Float(10)
        XCTAssertEqual(Float(0.5), Float(0.0).expressedAsPercentage(ofMinValue: minusTenToTenRange.lowerBound, maxValue: minusTenToTenRange.upperBound))
        XCTAssertEqual(Float(0.0), Float(-10).expressedAsPercentage(ofMinValue: minusTenToTenRange.lowerBound, maxValue: minusTenToTenRange.upperBound))
        XCTAssertEqual(Float(1.0), Float(10).expressedAsPercentage(ofMinValue: minusTenToTenRange.lowerBound, maxValue: minusTenToTenRange.upperBound))
        XCTAssertEqual(Float(-2.0), Float(-50).expressedAsPercentage(ofMinValue: minusTenToTenRange.lowerBound, maxValue: minusTenToTenRange.upperBound))
        XCTAssertEqual(Float(3.0), Float(50).expressedAsPercentage(ofMinValue: minusTenToTenRange.lowerBound, maxValue: minusTenToTenRange.upperBound))
        
        let minusThreeToMinusOneRange = Float(-3.0)...Float(-1.0)
        XCTAssertEqual(Float(0.5), Float(-2).expressedAsPercentage(ofMinValue: minusThreeToMinusOneRange.lowerBound, maxValue: minusThreeToMinusOneRange.upperBound))
        XCTAssertEqual(Float(0.0), Float(-3).expressedAsPercentage(ofMinValue: minusThreeToMinusOneRange.lowerBound, maxValue: minusThreeToMinusOneRange.upperBound))
        XCTAssertEqual(Float(1.0), Float(-1).expressedAsPercentage(ofMinValue: minusThreeToMinusOneRange.lowerBound, maxValue: minusThreeToMinusOneRange.upperBound))
        XCTAssertEqual(Float(-2.0), Float(-7).expressedAsPercentage(ofMinValue: minusThreeToMinusOneRange.lowerBound, maxValue: minusThreeToMinusOneRange.upperBound))
        XCTAssertEqual(Float(3.0), Float(3).expressedAsPercentage(ofMinValue: minusThreeToMinusOneRange.lowerBound, maxValue: minusThreeToMinusOneRange.upperBound))
    }
    
    func testMetricThresholdRangeMappingToState() {
        let provider = SingleValueMetricProvider(min: -1.0, current: 0.0, max: 1.0)
        let Limits = type(of: provider).self
        let range = MetricThresholdRange.lower
        let stateCritical = range.mapToState(1.0, on: Limits, threshold: 0.5)
        let stateNominal = range.mapToState(-0.5, on: Limits, threshold: 0.5)
        let stateNominalAtThreshold = range.mapToState(0.0, on: Limits, threshold: 0.5)
        
        let expectedStates: [MetricThresholdState] = [
            .critical(value: 1.0, percentage: 1.0),
            .nominal(value: -0.5, percentage: 0.25),
            .nominal(value: 0.0, percentage: 0.5)
        ]
        
        zip([stateCritical, stateNominal, stateNominalAtThreshold], expectedStates)
            .forEach { actualState, expectedState in
                XCTAssertEqual(actualState.value, expectedState.value)
                XCTAssertEqual(actualState.percentage, expectedState.percentage)
                XCTAssertEqual(actualState, expectedState)
            }
    }
}
