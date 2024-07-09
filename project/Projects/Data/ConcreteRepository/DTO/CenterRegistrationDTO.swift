//
//  CenterRegistrationDTO.swift
//  ConcreteRepository
//
//  Created by choijunios on 7/9/24.
//

import Foundation

struct CenterRegistrationDTO: Encodable {
    let identifier: String
    let password: String
    let phoneNumber: String
    let managerName: String
    let centerBusinessRegistrationNumber: String
}
