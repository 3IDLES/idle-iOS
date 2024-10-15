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
    var presentAlert: ((DefaultAlertContentVO) -> ())?
    
    var viewWillAppear: PublishSubject<Void> = .init()
    var tableData: Driver<[SectionInfo : [NotificationVO]]>?
    
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
            .map { info in
                
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
                
                return dict
            }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func createCellVM(vo: NotificationVO) -> NotificationCellViewModel {
        
        let cellViewModel = NotificationCellViewModel(notificationVO: vo)
        
        cellViewModel.presentAlert = self.presentAlert
        
        return cellViewModel
    }
}
