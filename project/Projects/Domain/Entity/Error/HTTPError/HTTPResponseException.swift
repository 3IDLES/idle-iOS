//
//  HTTPResponseException.swift
//  Entity
//
//  Created by choijunios on 7/14/24.
//

import Foundation


public struct HTTPResponseException: Error {
    
    public let status: HttpResponseStatus
    public let rawCode: String?
    public let timeStamp: String?
    
    public init(status: HttpResponseStatus, rawCode: String? = nil, timeStamp: String? = nil) {
        self.status = status
        self.rawCode = rawCode
        self.timeStamp = timeStamp
    }
}
