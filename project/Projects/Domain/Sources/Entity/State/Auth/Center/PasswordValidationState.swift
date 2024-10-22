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
            &&
            isEditingAndCheckingPasswordsEqual
        )
    }
    
    public func setEqualState(state: Bool) {
        isEditingAndCheckingPasswordsEqual = state
    }
}

public extension PasswordValidationState {
    
    var description: String {
        var descriptions: [String] = []
        
        if characterCount == .valid {
            descriptions.append("비밀번호 길이: 유효함 (8자 이상 20자 이하)")
        } else {
            descriptions.append("비밀번호 길이: 유효하지 않음 (8자 이상 20자 이하이어야 함)")
        }
        
        if alphabetAndNumberIncluded == .valid {
            descriptions.append("영문자와 숫자: 유효함 (영문자와 숫자가 모두 포함됨)")
        } else {
            descriptions.append("영문자와 숫자: 유효하지 않음 (영문자와 숫자가 반드시 포함되어야 함)")
        }
        
        if noEmptySpace == .valid {
            descriptions.append("공백 문자: 없음 (공백 문자를 사용할 수 없음)")
        } else {
            descriptions.append("공백 문자: 유효하지 않음 (공백 문자가 포함되어 있음)")
        }
        
        if unsuccessiveSame3words == .valid {
            descriptions.append("연속된 문자 3개 이상 사용: 유효함 (연속된 동일 문자가 없음)")
        } else {
            descriptions.append("연속된 문자 3개 이상 사용: 유효하지 않음 (연속된 동일 문자가 3개 이상 포함됨)")
        }
        
        return descriptions.joined(separator: "\n")
    }
}
