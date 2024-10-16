//
//  ExternalRequestService.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/20/24.
//

import Foundation


public protocol ExternalRequestService: NetworkService where TagetAPI == ExtenalUrlAPI { }

public class DefaultExternalRequestService: BaseNetworkService<ExtenalUrlAPI>, ExternalRequestService { }
