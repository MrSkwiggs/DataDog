//
//  MetricManagerTests.swift
//  
//
//  Created by Dorian Grolaux on 28/09/2022.
//

import XCTest
import Combine
@testable import Watcher

final class MetricManagerTests: XCTestCase {

    var manager: MetricManagerUseCase!
    var provider: MetricProviderUseCase!
    
    var subscriptions: [AnyCancellable] = []
    
    let metricValues: [Float] = [0.1, 0.9, 0.3, 0.7, 0.5]
    
    override func setUpWithError() throws {
        provider = MultipleValuesMetricProvider(values: metricValues)
        manager = makeManager()
    }
    
    func makeManager() -> MetricManagerUseCase {
        MetricManager(metricProvider: provider!,
                      threshold: 0.5,
                      thresholdRange: .lower,
                      refreshFrequency: 0.1, queue: .global())
    }
    
    override func tearDown() {
        subscriptions.forEach { $0.cancel() }
        subscriptions = []
    }
    
    func testValueDispatch() {
        let expectation = expectation(description: "sequential values over time")
        var valuesOverTime = metricValues
        manager
            .publisher
            .sink { value in
                print(value)
                XCTAssertEqual(value, valuesOverTime.removeFirst())
                if valuesOverTime.isEmpty { expectation.fulfill() }
            }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
            XCTAssertTrue(valuesOverTime.isEmpty)
        }
    }
    
    func testThresholdStateEvents() {
        var eventsOverTime: [MetricThresholdState] = [
            .nominal(value: 0.0, percentage: 0.0), // initial event
            .critical(value: metricValues[1], percentage: metricValues[1]), // 0.9
            .nominal(value: metricValues[2], percentage: metricValues[2]), // 0.3
            .critical(value: metricValues[3], percentage: metricValues[3]), // 0.7
        ]
        
        let expectation = expectation(description: "metric threshold state events over time")
        
        manager
            .thresholdStatePublisher
            .sink { state in
                let expectedState = eventsOverTime.removeFirst()
                XCTAssertEqual(state.value, expectedState.value)
                XCTAssertEqual(state.percentage, expectedState.percentage)
                XCTAssertEqual(state, expectedState)
                if eventsOverTime.isEmpty { expectation.fulfill() }
            }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
            XCTAssertTrue(eventsOverTime.isEmpty)
        }
    }
    
    func testNoDuplicateEvents() {
        
        let values: [Float] = [0.0, 0.2, 0.9, 0.8, 0.3, 0.4, 0.5]
        
        var expectedEventsOverTime: [MetricThresholdState] = [
            .nominal(value: values[0], percentage: values[0]), // 0.0
            .critical(value: values[2], percentage: values[2]), // 0.9
            .nominal(value: values[4], percentage: values[4]), // 0.3
        ]
        
        provider = MultipleValuesMetricProvider(values: values)
        manager = makeManager()
        
        let expectation = expectation(description: "no duplicate state events over time")
        
        manager
            .thresholdStatePublisher
            .sink { state in
                let expectedState = expectedEventsOverTime.removeFirst()
                XCTAssertEqual(state.value, expectedState.value)
                XCTAssertEqual(state.percentage, expectedState.percentage)
                XCTAssertEqual(state, expectedState)
                if expectedEventsOverTime.isEmpty { expectation.fulfill() }
            }
            .store(in: &subscriptions)
        
        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
            XCTAssertTrue(expectedEventsOverTime.isEmpty)
        }
    }
}
