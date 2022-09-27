//
//  Combine+Convenience.swift
//  DataDogApp
//
//  Created by Dorian Grolaux on 27/09/2022.
//

import Combine

extension CurrentValueSubject where Output == Int {
    
    /// Increments the subject by the given value.
    ///
    /// - parameter increment: The value to increment the subject by. Defaults to `1`
    func increment(by increment: Int = 1) {
        send(value + increment)
    }
}
