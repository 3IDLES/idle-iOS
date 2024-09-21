//
//  PostDetailForCenterBottomSheetVC.swift
//  CenterFeature
//
//  Created by choijunios on 8/28/24.
//

import UIKit
import PresentationCore
import BaseFeature
import RxCocoa
import RxSwift
import Entity
import DSKit

// MARK: 진행중인 공고
class OngoingPostOptionVC: IdleBottomSheetVC {
    
    // Init
    
    // View
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading3)
        label.textString = "공고 편집"
        label.textAlignment = .center
        return label
    }()
    let editPostButton: BottomSheetButton = .init(
        image: DSIcon.postEdit.image,
        titleText: "공고 수정하기",
        imageColor: DSColor.gray500.color,
        textColor: DSColor.gray900.color
    )
    private let closePostButton: BottomSheetButton = .init(
        image: DSIcon.postCheck.image,
        titleText: "채용 종료하기",
        imageColor: DSColor.red200.color,
        textColor: DSColor.red200.color
    )
    let closePostConfirmed: PublishRelay<Void> = .init()
    
    public override init() {
        super.init()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        setObservable()
    }
    
    private func setLayout() {
        
        let viewList = [
            titleLabel,
            Spacer(height: 20),
            editPostButton,
            Spacer(height: 8),
            closePostButton,
        ]
        
        let mainStack = VStack(viewList, alignment: .fill)
        
        super.setLayout(contentView: mainStack, margin: .init(top: 0, left: 20, bottom: 48, right: 20))
    }
    
    private func setObservable() {
        
        closePostButton
            .rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                let vm = PostOptionDefaultAlertVM(
                    title: "채용을 종료하시겠어요?",
                    description: "채용 종료 시 지원자 정보는 초기화됩니다.",
                    acceptButtonLabelText: "종료하기",
                    cancelButtonLabelText: "취소하기"
                ) { [weak self] in
                    self?.dismissView {
                        // presenter역할을 종료한 이후에 pop합니다.
                        self?.closePostConfirmed.accept(())
                    }
                }
                
                showIdleModal(viewModel: vm)
            })
            .disposed(by: disposeBag)
    }
    
    func bind(viewModel: PostDetailViewModelable) {
        
        editPostButton
            .rx.tap
            .map({ [weak self] _ in
                self?.dismissView()
            })
            .bind(to: viewModel.postEditButtonClicked)
            .disposed(by: disposeBag)
        
        closePostConfirmed
            .bind(to: viewModel.closePostButtonClicked)
            .disposed(by: disposeBag)
    }
}

// MARK: 지난 공고
class ClosedPostOptionVC: IdleBottomSheetVC {
    
    // Init
    
    // View
    let titleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading3)
        label.textString = "공고 편집"
        label.textAlignment = .center
        return label
    }()
    let removePostButton: BottomSheetButton = .init(
        image: DSIcon.trashBox.image,
        titleText: "공고 삭제하기",
        imageColor: DSColor.red200.color,
        textColor: DSColor.red200.color
    )
    
    let removeConfirmed: PublishRelay<Void> = .init()
    
    public override init() {
        super.init()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        setObservable()
    }
    
    private func setLayout() {
        
        let viewList = [
            titleLabel,
            removePostButton
        ]
        
        let mainStack = VStack(viewList, spacing: 20, alignment: .fill)
        
        super.setLayout(contentView: mainStack, margin: .init(top: 0, left: 20, bottom: 48, right: 20))
    }
    
    private func setObservable() {
        
        removePostButton
            .rx.tap
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                
                let vm = PostOptionDefaultAlertVM(
                    title: "공고를 삭제하시겠어요?",
                    description: "삭제 시 공고를 복구할 수 없어요.",
                    acceptButtonLabelText: "삭제하기",
                    cancelButtonLabelText: "취소하기"
                ) { [weak self] in
                    self?.dismissView {
                        self?.removeConfirmed.accept(())
                    }
                }
                
                showIdleModal(viewModel: vm)
            })
            .disposed(by: disposeBag)
    }
    
    func bind(viewModel: PostDetailViewModelable) {
        
        removeConfirmed
            .bind(to: viewModel.removePostButtonClicked)
            .disposed(by: disposeBag)
    }
}

fileprivate class PostOptionDefaultAlertVM: IdleAlertViewModelable {
    
    var title: String
    var description: String
    var acceptButtonLabelText: String
    var cancelButtonLabelText: String
    
    var acceptButtonClicked: RxRelay.PublishRelay<Void> = .init()
    var cancelButtonClicked: RxRelay.PublishRelay<Void> = .init()
     
    var dismiss: RxCocoa.Driver<Void>?
    
    init(
        title: String,
        description: String,
        acceptButtonLabelText: String,
        cancelButtonLabelText: String,
        onAccept: @escaping () -> ()
    ) {
        self.title = title
        self.description = description
        self.acceptButtonLabelText = acceptButtonLabelText
        self.cancelButtonLabelText = cancelButtonLabelText
        
        dismiss = Observable
            .merge(
                acceptButtonClicked.map({ [onAccept] _ in
                    onAccept()
                }),
                cancelButtonClicked.asObservable()
            )
            .asDriver(onErrorDriveWith: .never())
    }
}
