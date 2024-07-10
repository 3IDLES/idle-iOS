//
//  CenterRegisterState.swift
//  Entity
//
//  Created by choijunios on 7/9/24.
//

import Foundation

public class CenterRegisterState {
    public var name: String?
    public var phoneNumber: String?
    public var businessNumber: String?
    public var id: String?
    public var password: String?

    public init(
        name: String? = nil,
        phoneNumber: String? = nil,
        businessNumber: String? = nil,
        id: String? = nil,
        password: String? = nil
    ) {
        self.name = name
        self.phoneNumber = phoneNumber
        self.businessNumber = businessNumber
        self.id = id
        self.password = password
    }
    
    public func clear() {
        name = nil
        phoneNumber = nil
        businessNumber = nil
        id = nil
        password = nil
    }
    
    public var descroption: String {
        return "이름: \(name ?? "")\n전화번호: \(phoneNumber ?? "")\n비즈니스번호: \(businessNumber ?? "")\n아이디: \(id ?? "")\n패스워드: \(password ?? "")"
    }
}

