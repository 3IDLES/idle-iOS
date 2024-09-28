//
//  Entity.swift
//  ConcreteUseCase
//
//  Created by choijunios on 9/13/24.
//

import Foundation

public enum UnderLyingError: Error {
    
    case internetNotConnected
    case timeout
    case networkConnectionLost
    case unHandledError
}
