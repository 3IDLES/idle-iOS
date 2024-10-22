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

enum PagingRequest: Equatable {
    case initial
    case paging(nextPageId: String?)
}

struct NotificationTableDataInfo {
    
    let isRefreshed: Bool
    let data: [SectionInfo : [NotificationVO]]
}

class NotificationPageViewModel: BaseViewModel, NotificationPageViewModelable {
    
    // Injected
    @Injected var notificationsRepository: NotificationsRepository
    
    // Navigation
    var presentAlert: ((DefaultAlertObject) -> ())?
    var exitPage: (() -> ())?
    
    var viewWillAppear: PublishSubject<Void> = .init()
    var exitButtonClicked: PublishSubject<Void> = .init()
    
    
    // pagenation
    var requestInitialPageRequest: PublishSubject<Void> = .init()
    var requestNextPage: PublishSubject<Void> = .init()
    
    // Paging
    /// 값이 nil이라면 요청을 보내지 않습니다.
    var nextPagingRequest: PagingRequest? = .initial
    /// 가장최신의 데이터를 가집니다, 다음 요청시 해당데이터에 새로운 데이터를 더해서 방출
    private var currentNotificationList: [NotificationVO] = []
    
    // Output
    var tableData: Driver<NotificationTableDataInfo> = .empty()
    
    override init() {
        super.init()
        
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
                
                vm.currentNotificationList = []
                vm.nextPagingRequest = .initial
                
                return vm.notificationsRepository.notifcationList(next: nil)
            })
            .share()
        
        // MARK: 공고리스트 페이징 요청
        let pagingRequest = requestNextPage
            .compactMap { [weak self] _ in
                // 요청이 없는 경우 요청을 보내지 않는다.
                if let nextRequest = self?.nextPagingRequest, case .paging(let next) = nextRequest {
                    
                    return next
                }
                return nil
            }
            .unretained(self)
            .flatMap { (vm, nextRequestId) in
                
                vm.notificationsRepository
                    .notifcationList(next: nextRequestId)
            }
        
        let notificationRequestResult = Observable
            .merge(initialRequest, pagingRequest)
            .share()
        
        
        let fetchSuccess = notificationRequestResult.compactMap { $0.value }
        let fetchFailure = notificationRequestResult.compactMap { $0.error }
        
        fetchFailure.subscribe (onNext: { [weak self] error in
            
                let alertVO = DefaultAlertContentVO(
                    title: "알림리스트 획득 실패",
                    message: error.message
                )
            
                self?.alert.onNext(alertVO)
            })
            .disposed(by: disposeBag)
        
        
        tableData = fetchSuccess
            .unretained(self)
            .map { (vm: NotificationPageViewModel, currentInfo) in
                
                let (currentList, nextId) = currentInfo
                
                let isRefreshed: Bool = vm.nextPagingRequest == .initial
                
                // 다음 요청 설정
                var nextRequest: PagingRequest?
                if let nextId {
                    nextRequest = .paging(nextPageId: nextId)
                } else {
                    // 페이징 종료
                    nextRequest = nil
                }
                vm.nextPagingRequest = nextRequest
                
                var accum = vm.currentNotificationList
                accum.append(contentsOf: currentList)
                
                // 최근값 업데이트
                vm.currentNotificationList = accum
                
                // 날짜순 정렬
                let sortedInfo = accum.sorted { lhs, rhs in
                    lhs.createdDate < rhs.createdDate
                }
                
                var result: [SectionInfo: [NotificationVO]] = [:]
                
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
                    
                    if result[section] != nil {
                        result[section]!.append(item)
                    } else {
                        result[section] = [item]
                    }
                }
                
                return .init(
                    isRefreshed: isRefreshed,
                    data: result
                )
            }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func createCellVM(vo: NotificationVO) -> NotificationCellViewModel {
        
        let cellViewModel = NotificationCellViewModel(notificationVO: vo)
        
        cellViewModel.presentAlert = self.presentAlert
        
        return cellViewModel
    }
}
