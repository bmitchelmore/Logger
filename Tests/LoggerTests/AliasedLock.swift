//
//  File.swift
//  
//
//  Created by Blair Mitchelmore on 2024-03-03.
//

import Foundation
import os

// Because os.Logger exists, I get weird module
// conflicts if I import os and import Logger in
// the same class, so here's a hacky workaround
typealias AliasedLock = OSAllocatedUnfairLock
