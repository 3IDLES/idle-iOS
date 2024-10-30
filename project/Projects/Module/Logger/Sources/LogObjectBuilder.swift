//
//  LogObjectBuilder.swift
//  Logger
//
//  Created by choijunios on 10/31/24.
//

import Foundation

public protocol LogObjectBuilder {
    
    /// 로깅 오브젝트를 생성한다.
    func build() -> LoggingObject
}
