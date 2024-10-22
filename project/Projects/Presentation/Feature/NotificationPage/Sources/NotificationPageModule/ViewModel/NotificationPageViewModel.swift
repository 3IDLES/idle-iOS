//
//  NotificationPageViewModel.swift
//  NotificationPageFeature
//
//  Created by choijunios on 9/28/24.
//

import Foundation
import BaseFeature
import Domain
import Repository
import PresentationCore
import Core

import RxSwift
import RxCocoa

class NotificationPageViewModel: BaseViewModel, NotificationPageViewModelable {
    
    // Injected
    @Injected var notificationsRepository: NotificationsRepository
    
    // Navigation
    var presentAlert: ((DefaultAlertObject) -> ())?
    var exitPage: (() -> ())?
    
    var isFirst: Bool = true
    var viewWillAppear: PublishSubject<Void> = .init()
    var exitButtonClicked: PublishSubject<Void> = .init()
    
    
    // pagenation
    var requestInitialPageRequest: PublishSubject<Void> = .init()
    var requestNextPage: PublishSubject<Void> = .init()
    
    // Paging
    /// 값이 nil이라면 요청을 보내지 않습니다.
    var nextPagingRequest: PostPagingRequestForWorker? = .initial
    /// 가장최신의 데이터를 가집니다, 다음 요청시 해당데이터에 새로운 데이터를 더해서 방출
    private let currentNotificationList: BehaviorRelay<[NotificationVO]> = .init(value: [])
    
    var tableData: Driver<(Bool, [SectionInfo : [NotificationVO]])>?
    
    override init() {
        super.init()
        
        let fetchResult = viewWillAppear
            .unretained(self)
            .flatMap { (obj, _) in
                obj.notificationsRepository.notifcationList()
            }
            .share()
        
        let fetchSuccess = fetchResult.compactMap { $0.value }
        let fetchFailure = fetchResult.compactMap { $0.error }
        
        fetchFailure.subscribe (onNext: { [weak self] error in
            
                let alertVO = DefaultAlertContentVO(
                    title: "알림리스트 획득 실패",
                    message: error.message
                )
            
                self?.alert.onNext(alertVO)
            })
            .disposed(by: disposeBag)
        
        // MARK: 날짜를 바탕으로 섹션 필터링 후 반환
        tableData = fetchSuccess
            .unretained(self)
            .map { (obj, info) in
                
                // 날짜순 정렬
                let sortedInfo = info.sorted { lhs, rhs in
                    lhs.createdDate < rhs.createdDate
                }
                
                var dict: [SectionInfo: [NotificationVO]] = [:]
                
                for item in sortedInfo {
                    let diffSeconds = Date.now.timeIntervalSince(item.createdDate)
                    let diffDate = diffSeconds / (60 * 60 * 24)
                    var section: SectionInfo!
                    
                    switch diffDate {
                        case 0...1:
                            section = .today
                        case 1...7:
                            section = .week
                        case 8...30:
                            section = .month
                        default:
                            continue
                    }
                    
                    if dict[section] != nil {
                        dict[section]!.append(item)
                    } else {
                        dict[section] = [item]
                    }
                }
                
                defer {
                    if obj.isFirst {
                        obj.isFirst = false
                    }
                }
                
                return (obj.isFirst, dict)
            }
            .asDriver(onErrorDriveWith: .never())
        
        // MARK: Exit page
        exitButtonClicked
            .unretained(self)
            .subscribe(onNext: { (vm, _) in
                vm.exitPage?()
            })
            .disposed(by: disposeBag)
        
        
        // MARK: 알림 리스트 처음부터 요청하기
        let initialRequest = mapEndLoading(mapStartLoading(requestInitialPageRequest.asObservable())
            .unretained(self)
            .flatMap { (vm: NotificationPageViewModel, request) in
                
                vm.currentNotificationList.accept([])
                vm.nextPagingRequest = .initial
                
                return recruitmentPostUseCase
                    .getPostListForWorker(
                        request: .initial,
                        postCount: 10
                    )
            })
            .share()
    }
    
    func createCellVM(vo: NotificationVO) -> NotificationCellViewModel {
        
        let cellViewModel = NotificationCellViewModel(notificationVO: vo)
        
        cellViewModel.presentAlert = self.presentAlert
        
        return cellViewModel
    }
}
