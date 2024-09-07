//
//  CenterJoinStatusInfoVO.swift
//  Entity
//
//  Created by choijunios on 9/7/24.
//

import Foundation

public struct CenterJoinStatusInfoVO: Codable {
    public let id: String
    public let managerName: String
    public let phoneNumber: String
    public let centerManagerAccountStatus: AccountStatus
}

public enum AccountStatus: String, Codable {
    case pending = "PENDING"
    case approved = "APPROVED"
}
