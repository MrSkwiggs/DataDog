//
//  BackgroundTimerTests.swift
//  
//
//  Created by Dorian Grolaux on 28/09/2022.
//

import XCTest
@testable import Watcher

final class BackgroundTimerTests: XCTestCase {

    func testBlockIsDispatched() {
        var count = 0
        
        let expectation = expectation(description: "block dispatching")
        
        let timer = BackgroundTimer(timeInterval: 0.2) {
            count += 1
            
            if count == 3 { expectation.fulfill() }
        }
        timer.resume()
        
        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
    
    func testTimerDoesNotAutostart() {
        let expectation = expectation(description: "no autostart")
        expectation.isInverted = true
        
        let timer = BackgroundTimer(timeInterval: 0.2) {
            expectation.fulfill()
        }
        _ = timer
        
        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
        }
    }
    
    func testTimerSupsension() {
        let expectation = expectation(description: "timer suspension")
        expectation.isInverted = true
        
        var counter = 0
        
        var timer: BackgroundTimer!
        
        timer = BackgroundTimer(timeInterval: 0.2) {
            counter += 1
            
            if counter == 2 { timer.suspend() }
            
            if counter == 3 { expectation.fulfill() }
        }
        timer.resume()
        
        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error)
            XCTAssertEqual(counter, 2)
        }
    }
}
