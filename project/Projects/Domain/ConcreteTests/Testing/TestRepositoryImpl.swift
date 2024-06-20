//
//  TestRepositoryImpl.swift
//  Concrete
//
//  Created by 최준영 on 6/20/24.
//

import Foundation
import RepositoryInterface

class RepositoryImpl: RepositoryInterface {
    
    func getHelloMessage() -> String {
        return "Hello, World!"
    }
}
