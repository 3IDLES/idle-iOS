//
//  DefualtNotificationCellViewModel.swift
//  NotificationPageFeature
//
//  Created by choijunios on 9/28/24.
//

import UIKit
import Domain
import BaseFeature
import PresentationCore
import Repository
import Core


import RxSwift
import RxCocoa


class NotificationCellViewModel {
    
    // Injected
    @Injected var cacheRepository: CacheRepository
    @Injected var notificationsRepository: NotificationsRepository
    @Injected var remoteNotificationHelper: RemoteNotificationHelper
    
    // Navigation
    var presentAlert: ((DefaultAlertObject) -> ())?
    
    let notificationVO: NotificationVO
    
    // Input
    var cellClicked: PublishSubject<Void> = .init()
    
    // Output
    var isRead: Driver<Bool>?
    var profileImage: Driver<UIImage>?
    
    let disposeBag: DisposeBag = .init()
    
    init(notificationVO: NotificationVO) {
        self.notificationVO = notificationVO
        
        let isReadSubject = BehaviorSubject(value: notificationVO.isRead)
        
        // MARK: 읽음 정보
        isRead = isReadSubject
            .asDriver(onErrorDriveWith: .never())
        
        // MARK: 프로필 이미지
        
        if let imageDownloadInfo = notificationVO.imageDownloadInfo {
            profileImage = cacheRepository
                .getImage(imageInfo: imageDownloadInfo)
                .asDriver(onErrorDriveWith: .never())
        }
        
        // MARK: 클릭 이벤트
        
        /// 딥링크 처리
        cellClicked
            .unretained(self)
            .subscribe(onNext: { (obj, _) in
                
                guard let notificationDetails = notificationVO.notificationDetails else { return }
                
                obj.remoteNotificationHelper
                    .handleNotificationInApp(detail: notificationDetails)
            })
            .disposed(by: disposeBag)
        
        
        /// 읽음 처리
        let readRequestResult = cellClicked
            .unretained(self)
            .flatMap { (obj, _) in
                
                let notificationId = obj.notificationVO.id
                
                return obj.notificationsRepository
                    .readNotification(id: notificationId)
            }
            .share()
        
        let readRequestSuccess = readRequestResult.compactMap { $0.value }
        let readRequestFailure = readRequestResult.compactMap { $0.error }
        
        // 읽음 처리
        readRequestSuccess
            .map({ _ in true })
            .bind(to: isReadSubject)
            .disposed(by: disposeBag)
        
        // 읽기 실패
        readRequestFailure
            .unretained(self)
            .subscribe(onNext: { (obj, error) in
                
                let alertObject = DefaultAlertObject()
                    .setTitle("알림 확인 실패")
                    .setDescription(error.message)
                
                obj.presentAlert?(alertObject)
            })
            .disposed(by: disposeBag)
    }
    
    func getTimeText() -> String {
        
        let diff = Date.now.timeIntervalSince(notificationVO.createdDate)
        
        switch diff {
        case 0..<60:
            return "방금 전"
        case 0..<3600:
            // 1시간 이전
            return "\(Int(diff/60))분 전"
        case 0..<86400:
            // 1일내
            return "\(Int(diff/3600))시간 전"
        default:
            return "\(Int(diff/86400))일 전"
        }
    }
}
