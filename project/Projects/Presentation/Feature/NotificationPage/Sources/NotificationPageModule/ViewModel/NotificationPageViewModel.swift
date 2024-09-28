//
//  NotificationPageViewModel.swift
//  NotificationPageFeature
//
//  Created by choijunios on 9/28/24.
//

import Foundation
import BaseFeature

import RxSwift
import RxCocoa

class NotificationPageViewModel: BaseViewModel, NotificationPageViewModelable {
    
    var viewWillAppear: PublishSubject<Void> = .init()
    var tableData: Driver<[SectionInfo : [NotificationCellInfo]]>?
    
    override init() {
        super.init()
        
        
    }
    
    func createCellVM(info: NotificationCellInfo) -> NotificationCellViewModelable {
        
        NotificationCellViewModel(cellInfo: info)
    }
}
