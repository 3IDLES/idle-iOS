//
//  NotificationRepositoryMockTest.swift
//  DataTests
//
//  Created by choijunios on 10/15/24.
//

import XCTest
import Repository
import DataSource
import Core


import RxSwift
import Swinject

final class NotificationRepositoryMockTest: XCTestCase {
    
    let disposeBag = DisposeBag()

    static override func setUp() {
        
        DependencyInjector.shared.assemble([
            TestAssembly()
        ])
    }
    
    func testNotificationList() throws {
        
        let expectation = expectation(description: "DefaultNotificationsRepositoryTest")
        
        let repository = DefaultNotificationsRepository()
        
        let readResult = repository
            .readNotification(id: "-1")
            .asObservable()
            .share()
        let readSuccess = readResult.compactMap { $0.value }
        let readFailure = readResult.compactMap { $0.error }
        
        let unreadNotificationCountResult = repository
            .unreadNotificationCount()
            .asObservable()
            .share()
        let unreadNotificationCountSuccess = unreadNotificationCountResult.compactMap { $0.value }
        let unreadNotificationCountFailure = unreadNotificationCountResult.compactMap { $0.error }

        let notifcationListResult = repository
            .notifcationList()
            .asObservable()
            .share()
        let notifcationListSuccess = notifcationListResult.compactMap { $0.value }
        let notifcationListFailure = notifcationListResult.compactMap { $0.error }
        
        Observable.combineLatest(
            readSuccess.asObservable(),
            unreadNotificationCountSuccess.asObservable(),
            notifcationListSuccess.asObservable()
        )
        .subscribe { (_, count, notifications) in
            
            print("수: \(count)")
            print(notifications)
            
            expectation.fulfill()
        }
        .disposed(by: disposeBag)
        
        Observable.merge(
            readFailure.asObservable(),
            unreadNotificationCountFailure.asObservable(),
            notifcationListFailure.asObservable()
        )
        .subscribe(onNext: { (domainError) in
              
            XCTFail(domainError.message)
        })
        .disposed(by: disposeBag)
        
        wait(for: [expectation], timeout: 20)
    }
}

class TestAssembly: Assembly {
    
    func assemble(container: Swinject.Container) {
        container.register(KeyValueStore.self) { _ in
            TestKeyValueStore()
        }
    }
}
