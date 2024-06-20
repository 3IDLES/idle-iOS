//
//  NetworkConcrete.swift
//  ProjectDescriptionHelpers
//
//  Created by 최준영 on 6/21/24.
//

import Foundation
import NetworkInterface

public class DefaultNetworkDataSource: NetworkDataSource {
    
    public func reqeust() -> String {
        return "Hello, Network!"
    }
}
