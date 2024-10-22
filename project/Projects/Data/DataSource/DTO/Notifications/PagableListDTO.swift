//
//  PagableListDTO.swift
//  DataSource
//
//  Created by choijunios on 10/22/24.
//

import Foundation

public struct PagableListDTO<T: Decodable>: Decodable {

    public let items: [T]
    public let next: String?
    public let total: Int
}
