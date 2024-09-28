//
//  NotificationPageViewModel.swift
//  NotificationPageFeature
//
//  Created by choijunios on 9/28/24.
//

import Foundation
import BaseFeature
import Entity
import UseCaseInterface
import ConcreteRepository
import PresentationCore

import RxSwift
import RxCocoa

class NotificationPageViewModel: BaseViewModel, NotificationPageViewModelable {
    
    @Injected var notificationUseCase: NotificationUseCase
    
    var viewWillAppear: PublishSubject<Void> = .init()
    var tableData: Driver<[SectionInfo : [NotificationCellInfo]]>?
    
    override init() {
        super.init()
        
        viewWillAppear
            .flatMap { [notificationUseCase] _ in
                notificationUseCase
            }
    }
    
    func createCellVM(info: NotificationCellInfo) -> NotificationCellViewModelable {
        
        NotificationCellViewModel(cellInfo: info)
    }
}
