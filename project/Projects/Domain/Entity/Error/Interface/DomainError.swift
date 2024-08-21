//
//  DomainError.swift
//  Entity
//
//  Created by choijunios on 7/14/24.
//

import Foundation

public protocol DomainError: RawRepresentable, Error where RawValue == String {
    
    var message: String { get }
    
    static var undefinedError: Self { get }
}
