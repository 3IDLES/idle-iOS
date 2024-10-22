//
//  PasswordValidationState.swift
//  Domain
//
//  Created by choijunios on 10/22/24.
//

import Foundation

public class PasswordValidationState {
    
    public enum State {
        case valid
        case invalid
    }
    
    public let characterCount: State
    public let alphabetAndNumberIncluded: State
    public let noEmptySpace: State
    public let unsuccessiveSame3words: State
    public private(set) var isEditingAndCheckingPasswordsEqual: Bool = false
    
    public init(
        characterCount: State,
        alphabetAndNumberIncluded: State,
        noEmptySpace: State,
        unsuccessiveSame3words: State
    ) {
        self.characterCount = characterCount
        self.alphabetAndNumberIncluded = alphabetAndNumberIncluded
        self.noEmptySpace = noEmptySpace
        self.unsuccessiveSame3words = unsuccessiveSame3words
    }
    
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
    
    public func setEqualState(state: Bool) {
        isEditingAndCheckingPasswordsEqual = state
    }
}
