//
//  CenterRegisterState.swift
//  Entity
//
//  Created by choijunios on 7/9/24.
//

import Foundation

public class CenterRegisterState {
    public var name: String
    public var phoneNumber: String
    public var businessNumber: String
    public var id: String
    public var password: String

    public init(
        name: String = "",
        phoneNumber: String = "",
        businessNumber: String = "",
        id: String = "",
        password: String = ""
    ) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.businessNumber = businessNumber
        self.id = id
        self.password = password
    }
    
    public var description: String {
        return "name: \(name), phoneNumber: \(phoneNumber), businessNumber: \(businessNumber), id: \(id), password: \(password)"
    }
    
    public func clear() {
        name = ""
        phoneNumber = ""
        businessNumber = ""
        id = ""
        password = ""
    }
}

