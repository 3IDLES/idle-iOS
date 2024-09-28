//
//  DefaultNotificationPageUseCase.swift
//  ConcreteUseCase
//
//  Created by choijunios on 9/28/24.
//

import Foundation
import UseCaseInterface
import Entity


import RxSwift

public class TestNotificationPageUseCase: NotificationPageUseCase {
    
    public init() { }
    
    public func getNotificationList() -> Single<Result<[NotificationCellInfo], DomainError>> {
        
        let task = Single<[NotificationCellInfo]>.create { observer in
            
            var mockData: [NotificationCellInfo] = []
            
            // 오늘
            mockData.append(
                contentsOf: (0..<5).map { _ in NotificationCellInfo.create(createdDay: 0) }
            )
            
            // 4일전
            mockData.append(
                contentsOf: (0..<5).map { _ in NotificationCellInfo.create(createdDay: -4) }
            )
            
            // 15일전
            mockData.append(
                contentsOf: (0..<5).map { _ in NotificationCellInfo.create(createdDay: -15) }
            )
            
            observer(.success(mockData))
            
            
            return Disposables.create { }
        }
        
        return convert(task: task)
    }
}
