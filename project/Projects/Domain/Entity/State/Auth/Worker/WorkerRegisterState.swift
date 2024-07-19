//
//  WorkerRegisterState.swift
//  Entity
//
//  Created by choijunios on 7/14/24.
//

import Foundation

public enum Gender {
    case notDetermined
    case male
    case female
    
    public var str: String {
        switch self {
        case .notDetermined:
            "무결"
        case .male:
            "남성"
        case .female:
            "여성"
        }
    }
}

public class WorkerRegisterState {
    public var name: String = ""
    public var gender: Gender = .notDetermined
    public var phoneNumber: String = ""
    public var addressInformation: AddressInformation = .init(roadAddress: "", jibunAddress: "")
    public var detailAddress: String = ""
    
    public init() { }
    
    public func clear() {
        name = ""
        gender = .notDetermined
        phoneNumber = ""
        addressInformation.roadAddress = ""
        addressInformation.jibunAddress = ""
        detailAddress = ""
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
