//
//  DataSourceError.swift
//  NetworkDataSource
//
//  Created by choijunios on 7/10/24.
//

import Foundation

public enum DataSourceError: Error {
    
    case decodingError
    case localStorageSaveFailure
    case localStorageFetchFailure
}
