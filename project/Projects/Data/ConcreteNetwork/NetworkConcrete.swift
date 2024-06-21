//
//  NetworkConcrete.swift
//  ProjectDescriptionHelpers
//
//  Created by 최준영 on 6/21/24.
//

import Foundation
import NetworkInterface
import Alamofire

public class DefaultNetworkDataSource: NetworkDataSource {
    
    public func reqeust() -> String {
        
        AF.request("https://www.google.com").response { response in
            debugPrint(response)
        }
        
        return "Hello, Network!"
    }
}
