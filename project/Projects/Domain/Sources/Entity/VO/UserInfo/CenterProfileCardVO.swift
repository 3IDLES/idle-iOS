//
//  CenterProfileCardVO.swift
//  Entity
//
//  Created by choijunios on 7/29/24.
//

import Foundation

public struct CenterProfileCardVO {
    public let name: String
    public let location: String
    
    public init(name: String, location: String) {
        self.name = name
        self.location = location
    }
    
    public static let `default` = CenterProfileCardVO(name: "내 센터", location: "내 센터 위치")
}
