//
//  Logger.swift
//  Logger
//
//  Created by choijunios on 10/30/24.
//

import Foundation


public protocol LoggingObject {
    var eventType: String { get }
    var properties: [String: Any] { get }
}

public protocol Logger {
    
    func send(_ object: LoggingObject)
}

