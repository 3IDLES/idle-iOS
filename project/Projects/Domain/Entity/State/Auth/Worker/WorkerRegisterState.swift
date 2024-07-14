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
}

public class WorkerRegisterState {
    public var name: String = ""
    public var gender: Gender = .notDetermined
    public var phoneNumber: String = ""
    public var postalCode: String = ""
    public var detailAddress: String = ""
    
    public init() { }
    
    public func clear() {
        name = ""
        gender = .notDetermined
        phoneNumber = ""
        postalCode = ""
        detailAddress = ""
    }
}
