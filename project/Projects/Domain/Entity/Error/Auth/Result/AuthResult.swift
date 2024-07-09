//
//  AuthResult.swift
//  Entity
//
//  Created by choijunios on 7/9/24.
//

import Foundation

public typealias PhoneNumberAuthResult = Result<Bool, IdleError>
public typealias BusinessNumberAuthResult = Result<BusinessInfoVO, IdleError>
