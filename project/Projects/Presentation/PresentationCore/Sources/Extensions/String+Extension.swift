//
//  String+Extension.swift
//  PresentationCore
//
//  Created by choijunios on 8/14/24.
//

import Foundation

public extension String {
    
    func emptyDefault(_ str: String) -> String {
        self.isEmpty ? str : self
    }
}
