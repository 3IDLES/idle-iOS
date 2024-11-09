//
//  ChattingListFeatureFactory.swift
//  Chatting
//
//  Created by choijunios on 11/5/24.
//

import ChattingFeatureInterface
import Core

public class DefaultChattingListFeatureFactory: ChattingListFeatureFactory {
    
    public init() { }
    
    public func createModule() -> Module {
        
        let viewModel: ChattingListViewModel = .init()
        
        //
        
        let viewController: ChattingListViewController = .init()
        viewController.bind(viewModel: viewModel)
        
        return viewController
    }
}
