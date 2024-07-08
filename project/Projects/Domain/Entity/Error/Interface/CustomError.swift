//
//  CustomError.swift
//  Entity
//
//  Created by choijunios on 7/8/24.
//

import Foundation

public protocol CustomError: RawRepresentable, Error where RawValue == String {
    
    var message: String { get }
    
    static var undefinedError: Self { get }
}
