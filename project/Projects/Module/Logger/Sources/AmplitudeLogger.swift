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
                apiKey: "AmplitudeConfig.apiKey"
            )
        )
        
        objectPublisher
            .throttle(for: 0.3, scheduler: DispatchQueue.main, latest: true)
            .sink { object in
                
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
