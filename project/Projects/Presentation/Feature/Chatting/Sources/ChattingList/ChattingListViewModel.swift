//
//  ChattingListViewModel.swift
//  Chatting
//
//  Created by choijunios on 11/5/24.
//

import Foundation

import BaseFeature
import Domain


import RxSwift
import RxCocoa

class ChattingListViewModel: BaseViewModel {
    
    // input
    let viewDidLoad: PublishSubject<Void> = .init()
    
    // output
    var chatListItems: Driver<[ChattingListItemVO]> = .never()
    
    override init() {
        
        super.init()
        
        chatListItems = viewDidLoad
            .unretained(self)
            .flatMap { (vm, _) in
                let vos = (0..<30).map { index in
                    let id = "\(index)"
                    return ChattingListItemVO.createMock(id: id)
                }
                return Observable.just(vos)
            }
            .asDriver(onErrorDriveWith: .never())
    }
}

extension ChattingListItemVO {
    
    static func createMock(id: String) -> ChattingListItemVO {
        .init(
            id: id,
            counterPartName: "세얼간이요양센터",
            latestChat: "안녕하세요 문의드리고 싶어서 연락드렸어요",
            latestChatTime: .now
        )
    }
}
