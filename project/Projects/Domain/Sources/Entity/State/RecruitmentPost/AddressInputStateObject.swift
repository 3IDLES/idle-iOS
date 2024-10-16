//
//  AddressInputStateObject.swift
//  Entity
//
//  Created by choijunios on 8/7/24.
//

import Foundation

public class AddressInputStateObject: NSCopying {
    
    public var addressInfo: AddressInformation?
    
    public init() { }
    
    public static let mock: AddressInputStateObject = {
       
        let data = AddressInputStateObject()
        data.addressInfo = .init(roadAddress: "서울특별시 중구 순화동 151", jibunAddress: "서울특별시 중구 순화동 151")
        return data
    }()
    
    public func copy(with zone: NSZone? = nil) -> Any {
        let copy = AddressInputStateObject()
        copy.addressInfo = self.addressInfo
        return copy
    }
}
