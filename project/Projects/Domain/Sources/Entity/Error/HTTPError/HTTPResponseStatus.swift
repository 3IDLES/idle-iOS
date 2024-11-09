//
//  HTTPResponseStatus.swift
//  Entity
//
//  Created by choijunios on 7/14/24.
//

import Foundation

public enum HttpResponseStatus: Int {
    case ok = 200
    case created = 201
    case accepted = 202
    case notAuthoritative = 203
    case noContent = 204
    case reset = 205
    case partial = 206
    case multChoice = 300
    case movedPerm = 301
    case movedTemp = 302
    case seeOther = 303
    case notModified = 304
    case useProxy = 305
    case badRequest = 400
    case unauthorized = 401
    case paymentRequired = 402
    case forbidden = 403
    case notFound = 404
    case badMethod = 405
    case notAcceptable = 406
    case proxyAuth = 407
    case clientTimeout = 408
    case conflict = 409
    case gone = 410
    case lengthRequired = 411
    case preconFailed = 412
    case entityTooLarge = 413
    case reqTooLong = 414
    case unsupportedType = 415
    case reqTooMany = 429
    case internalError = 500
    case notImplemented = 501
    case badGateway = 502
    case unavailable = 503
    case gatewayTimeout = 504
    case version = 505
    case unknownError = 520
    case unknown = -1

    public var message: String {
        switch self {
        case .ok: return "Ok"
        case .created: return "Created"
        case .accepted: return "Accepted"
        case .notAuthoritative: return "Not Authoritative"
        case .noContent: return "No Content"
        case .reset: return "Reset"
        case .partial: return "Partial"
        case .multChoice: return "Mult Choice"
        case .movedPerm: return "Moved Perm"
        case .movedTemp: return "Moved Temp"
        case .seeOther: return "See Other"
        case .notModified: return "Not Modified"
        case .useProxy: return "Use Proxy"
        case .badRequest: return "Bad Request"
        case .unauthorized: return "Unauthorized"
        case .paymentRequired: return "Payment Required"
        case .forbidden: return "Forbidden"
        case .notFound: return "Not Found"
        case .badMethod: return "Bad Method"
        case .notAcceptable: return "Not Acceptable"
        case .proxyAuth: return "Proxy Auth"
        case .clientTimeout: return "Client Timeout"
        case .conflict: return "Conflict"
        case .gone: return "Gone"
        case .lengthRequired: return "Length Required"
        case .preconFailed: return "Precon Failed"
        case .entityTooLarge: return "Entity Too Large"
        case .reqTooLong: return "Req Too Long"
        case .unsupportedType: return "Unsupported Type"
        case .reqTooMany: return "Req Too Many"
        case .internalError: return "Internal Error"
        case .notImplemented: return "Not Implemented"
        case .badGateway: return "Bad Gateway"
        case .unavailable: return "Unavailable"
        case .gatewayTimeout: return "Gateway Timeout"
        case .version: return "Version"
        case .unknownError: return "Unknown Error"
        case .unknown: return "Unknown"
        }
    }

    public static func create(code: Int) -> HttpResponseStatus {
        return HttpResponseStatus(rawValue: code) ?? .unknown
    }
}
