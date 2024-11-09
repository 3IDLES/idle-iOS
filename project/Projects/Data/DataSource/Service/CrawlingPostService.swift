//
//  CrawlingPostService.swift
//  DataSource
//
//  Created by choijunios on 9/6/24.
//

import Foundation


public protocol CrawlingPostService: NetworkService where TagetAPI == CrawlingPostAPI { }

public class DefaultCrawlingPostService: BaseNetworkService<CrawlingPostAPI>, CrawlingPostService { }
