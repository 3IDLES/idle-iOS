//
//  DefualtNotificationCellViewModel.swift
//  NotificationPageFeature
//
//  Created by choijunios on 9/28/24.
//

import UIKit


import RxSwift
import RxCocoa
import PresentationCore
import ConcreteRepository

class NotificationCellViewModel: NotificationCellViewModelable {
    
    @Injected var cacheRepository: CacheRepository
    
    let cellInfo: NotificationCellInfo
    
    // Inout
    var cellClicked: PublishSubject<Void> = .init()
    
    // Output
    var isRead: Driver<Bool>?
    var profileImage: Driver<UIImage>?
    
    let disposeBag: DisposeBag = .init()
    
    init(cellInfo: NotificationCellInfo) {
        self.cellInfo = cellInfo
        
        let isReadSubject = BehaviorSubject(value: cellInfo.isRead)
        
        // MARK: 읽음 정보
        isRead = isReadSubject
            .asDriver(onErrorDriveWith: .never())
        
        // MARK: 프로필 이미지
        profileImage = cacheRepository
            .getImage(imageInfo: cellInfo.imageInfo)
            .asDriver(onErrorDriveWith: .never())
        
        // MARK: 클릭 이벤트
        cellClicked
            .subscribe(onNext: { [isReadSubject] _ in
                
                // 읽음 처리
                isReadSubject.onNext(true)
                
                // 알림 디테일로 이동
                let _ = cellInfo.id
            })
            .disposed(by: disposeBag)
    }
}
