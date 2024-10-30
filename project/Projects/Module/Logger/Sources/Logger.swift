//
//  Logger.swift
//  Logger
//
//  Created by choijunios on 10/30/24.
//

import Foundation


public protocol LoggingObject {
    
    var properties: [String: Any] { get }
}

public protocol Logger {
    
    func send(_ object: LoggingObject)
}

