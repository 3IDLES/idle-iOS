//
//  TokenDTO.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/14/24.
//

import Foundation

public struct TokenDTO: Decodable {
    public let accessToken: String?
    public let refreshToken: String?
}
