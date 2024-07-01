//
//  DebugLog.swift
//  PresentationCore
//
//  Created by choijunios on 7/1/24.
//

import Foundation

public func printIfDebug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    print(items, separator: separator, terminator: terminator)
    #endif
}
