//
//  DisposableViewController.swift
//  PresentationCore
//
//  Created by choijunios on 6/30/24.
//

import UIKit

public protocol DisposableObject: AnyObject {
    
    func cleanUp()
}

public typealias DisposableViewController = UIViewController & DisposableObject
