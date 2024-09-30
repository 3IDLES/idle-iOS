//
//  AmplitudeLogger.swift
//  ConcreteLogger
//
//  Created by choijunios on 9/16/24.
//

import Foundation
import PresentationCore
import Domain

import AmplitudeSwift

public class AmplitudeLogger: LoggerMessagePublisher {
    
    public var timerDict: [String : Date] = [:]
    public var timerQueue: DispatchQueue = .global(qos: .utility)
    
    let amplitude: Amplitude

    public init() { 
        
        self.amplitude = Amplitude(
            configuration: Configuration(
                apiKey: AmplitudeConfig.apiKey
            )
        )
            
        // 유저 아이디 설정
        setUserId(id: getAnonymousUserId())
    }
    
    public func send(event: LoggingEvent) {
        var eventProperties: [String: Any] = [:]
        
        event.properties.forEach { (key, value) in
            eventProperties[key.rawValue] = value
        }
        
        amplitude
            .track(eventType: event.type.rawValue, eventProperties: eventProperties)
    }
    
    public func setUserId(id: String) {
        amplitude.setUserId(userId: id)
    }
}
