//
//  UserInformationService.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/20/24.
//

import Foundation

public protocol UserInformationService: NetworkService where TagetAPI == UserInformationAPI { }

public class DefaultUserInformationService: BaseNetworkService<UserInformationAPI>, UserInformationService { }
