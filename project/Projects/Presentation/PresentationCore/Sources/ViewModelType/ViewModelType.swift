//
//  ViewModelType.swift
//  PresentationCore
//
//  Created by choijunios on 7/6/24.
//

import Foundation

public protocol ViewModelType: AnyObject {
    
    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
    
    func transform(input: Input) -> Output
}
