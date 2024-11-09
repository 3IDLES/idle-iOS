//
//  ApplyService.swift
//  DataSource
//
//  Created by choijunios on 9/3/24.
//

import Foundation

public protocol ApplyService: NetworkService where TagetAPI == ApplyAPI { }

public class DefaultApplyService: BaseNetworkService<ApplyAPI>, ApplyService { }
