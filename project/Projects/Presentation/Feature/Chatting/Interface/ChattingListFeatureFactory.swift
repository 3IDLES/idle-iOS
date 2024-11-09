//
//  ChattingListFeatureFactory.swift
//  Chatting
//
//  Created by choijunios on 11/5/24.
//

import UIKit

public protocol ChattingListFeatureFactory {
    
    typealias Module = UIViewController
    
    func createModule() -> Module
}
