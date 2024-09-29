//
//  Injected.swift
//  Core
//
//  Created by choijunios on 9/16/24.
//

import Foundation

@propertyWrapper
public class Injected<T> {
    
    public let wrappedValue: T
    
    public init() {
        self.wrappedValue = DependencyInjector.shared.resolve()
    }
}
