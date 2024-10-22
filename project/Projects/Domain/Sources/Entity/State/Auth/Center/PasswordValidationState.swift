//
//  PasswordValidationState.swift
//  Domain
//
//  Created by choijunios on 10/22/24.
//

import Foundation

public struct PasswordValidationState {
    
    public enum State {
        case valid
        case invalid
    }
    
    public let characterCount: State
    public let alphabetAndNumberIncluded: State
    public let noEmptySpace: State
    public let unsuccessiveSame3words: State
    
    public var isValid: Bool {
        
        return (
            characterCount == .valid
            &&
            alphabetAndNumberIncluded == .valid
            &&
            noEmptySpace == .valid
            &&
            unsuccessiveSame3words == .valid
        )
    }
}
