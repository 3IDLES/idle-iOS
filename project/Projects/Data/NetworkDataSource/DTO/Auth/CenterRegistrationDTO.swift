//
//  CenterRegistrationDTO.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/14/24.
//

import Foundation

public struct CenterRegistrationDTO: Encodable {
    public let identifier: String
    public let password: String
    public let phoneNumber: String
    public let managerName: String
    public let centerBusinessRegistrationNumber: String
    
    public init(identifier: String, password: String, phoneNumber: String, managerName: String, centerBusinessRegistrationNumber: String) {
        self.identifier = identifier
        self.password = password
        self.phoneNumber = phoneNumber
        self.managerName = managerName
        self.centerBusinessRegistrationNumber = centerBusinessRegistrationNumber
    }
}
