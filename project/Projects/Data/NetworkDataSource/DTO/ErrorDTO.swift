//
//  ErrorDTO.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/14/24.
//

import Foundation
import Entity

public struct ErrorDTO: Decodable {
    
    public var code: String?
    public var timestamp: String?
    
    enum CodingKeys: String, CodingKey {
        case code
        case timestamp
    }
}
