//
//  RecruitmentPostService.swift
//  NetworkDataSource
//
//  Created by choijunios on 8/8/24.
//

import Foundation


public protocol RecruitmentPostService: NetworkService where TagetAPI == RcruitmentPostAPI { }

public class DefaultRecruitmentPostService: BaseNetworkService<RcruitmentPostAPI>, RecruitmentPostService { }
