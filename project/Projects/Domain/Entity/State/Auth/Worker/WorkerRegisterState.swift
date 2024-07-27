//
//  WorkerRegisterState.swift
//  Entity
//
//  Created by choijunios on 7/14/24.
//

import Foundation

public class WorkerRegisterState {
    public var name: String = ""
    public var gender: Gender = .notDetermined
    public var birthYear: Int = 0
    public var phoneNumber: String = ""
    public var addressInformation: AddressInformation = .init(roadAddress: "", jibunAddress: "")
    
    public init() { }
    
    public func clear() {
        name = ""
        gender = .notDetermined
        birthYear = 0
        phoneNumber = ""
        addressInformation.roadAddress = ""
        addressInformation.jibunAddress = ""
    }
}

public class AddressInformation {
    public var roadAddress: String
    public var jibunAddress: String
    
    public init(roadAddress: String, jibunAddress: String) {
        self.roadAddress = roadAddress
        self.jibunAddress = jibunAddress
    }
}
