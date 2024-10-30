//
//  AmplitudeLogger.swift
//  Logger
//
//  Created by choijunios on 10/30/24.
//

import Foundation
import Combine


import AmplitudeSwift

public class AmplitudeLogger: Logger {
    
    private let objectPublisher: PassthroughSubject<LoggingObject, Never> = .init()
    
    private var bag: Set<AnyCancellable> = .init()
    
    private let amplitude: Amplitude
    
    public init() {
        
        self.amplitude = Amplitude(
            configuration: Configuration(
                apiKey: AmplitudeConfig.apiKey
            )
        )
        
        objectPublisher
            .throttle(for: 0.3, scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] object in
                
                let eventType = object.eventType
                let eventProperties = object.properties
                
                self?.amplitude.track(eventType: eventType, eventProperties: eventProperties)
            }
            .store(in: &bag)
    }
    
    public func setUserId(id: String) {
        amplitude.setUserId(userId: id)
    }
    
    public func send(_ object: any LoggingObject) {
        objectPublisher.send(object)
    }
}
