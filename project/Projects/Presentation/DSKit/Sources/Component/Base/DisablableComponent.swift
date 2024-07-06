//
//  DisablableComponent.swift
//  DSKit
//
//  Created by choijunios on 7/6/24.
//

import Foundation
import UIKit

public protocol DisablableComponent: UIResponder {
    
    var isEnabled: Bool { get }
    
    func setEnabled(_ isEnabled: Bool)
}
