//
//  File.swift
//  
//
//  Created by Blair Mitchelmore on 2024-03-03.
//

import Foundation
import os

final class FormatterStorage<T>: @unchecked Sendable {
    private let lock: OSAllocatedUnfairLock<[String?:T]>
    private let builder: (String?) -> T
    
    init(builder: @escaping (String?) -> T) {
        self.lock = OSAllocatedUnfairLock(initialState: [:])
        self.builder = builder
    }
    
    subscript(_ identifier: String?) -> T {
        get {
            lock.withLock { formatters in
                if let formatter = formatters[identifier] {
                    return formatter
                } else {
                    let formatter = builder(identifier)
                    formatters[identifier] = formatter
                    return formatter
                }
            }
        }
    }
}

func DateFormatterStorage() -> FormatterStorage<DateFormatter> {
    return FormatterStorage(builder: BuildDateFormatter)
}

func LevelFormatterStorage() -> FormatterStorage<LevelFormatter> {
    return FormatterStorage(builder: BuildLevelFormatter)
}
