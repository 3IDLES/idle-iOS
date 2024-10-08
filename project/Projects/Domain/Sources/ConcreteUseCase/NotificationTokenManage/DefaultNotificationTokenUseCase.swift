//
//  DefaultNotificationTokenUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 9/26/24.
//

import Foundation

public class DefaultNotificationTokenUseCase: NotificationTokenUseCase {
    
    
    
    public init() { }
    
    public func setNotificationToken(token: String, completion: @escaping (Bool) -> ()) {
        
        //TODO: 구체적 스팩 산정 후 구현
        completion(true)
    }
    
    public func deleteNotificationToken(completion: @escaping (Bool) -> ()) {
        
        //TODO: 구체적 스팩 산정 후 구현
        completion(true)
    }
}
