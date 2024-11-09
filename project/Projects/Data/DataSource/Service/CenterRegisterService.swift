//
//  AuthService.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/8/24.
//

import Foundation

public protocol AuthService: NetworkService where TagetAPI == AuthAPI { }

public class DefaultAuthService: BaseNetworkService<AuthAPI>, AuthService { }
