//
//  File.swift
//  
//
//  Created by Blair Mitchelmore on 2024-03-03.
//

import Foundation
import Logger
import LogFoundation

final class TestLogger: LoggerDestination {
    let lock: AliasedLock<[LogEntry]>
    
    init() {
        lock = AliasedLock(initialState: [])
    }
    
    func log(_ entry: LogEntry) {
        lock.withLock { entries in
            entries.append(entry)
        }
    }
}
