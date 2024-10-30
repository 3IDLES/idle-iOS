//
//  MockLogger.swift
//  Logger
//
//  Created by choijunios on 10/30/24.
//

import Foundation

public class MockLogger: Logger {
    
    public init() { }
    
    public func send(_ object: any LoggingObject) {
        print(object.properties)
    }
}
