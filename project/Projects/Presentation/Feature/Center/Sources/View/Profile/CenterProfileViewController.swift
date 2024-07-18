//
//  CenterProfileViewController.swift
//  CenterFeature
//
//  Created by choijunios on 7/17/24.
//

import UIKit
import PresentationCore
import RxSwift
import RxCocoa
import DSKit
import Entity

public protocol CenterProfileViewModelable where Input: CenterProfileInputable, Output: CenterProfileOutputable {
    associatedtype Input
    associatedtype Output
    var input: Input { get }
    var output: Output? { get }
    
    func requestData()
}

public protocol CenterProfileInputable {
    var editingButtonPressed: PublishRelay<Void> { get }
    var editingFinishButtonPressed: PublishRelay<Void> { get }
    var editingPhoneNumber: BehaviorRelay<String> { get }
    var editingInstruction: BehaviorRelay<String> { get }
    var editingImage: BehaviorRelay<UIImage> { get }
}

public protocol CenterProfileOutputable {
    var centerName: Driver<String> { get }
    var centerLocation: Driver<String> { get }
    var centerPhoneNumber: Driver<String> { get }
    var centerIntroduction: Driver<String> { get }
    var centerImage: Driver<UIImage> { get }
    var isEditingMode: Driver<Bool> { get }
    var editingValidation: Driver<Void> { get }
    var alert: Driver<DefaultAlertContentVO> { get }
}

public class CenterProfileViewController: DisposableViewController {
    
    var viewModel: (any CenterProfileViewModelable)?
    
    let navigationBar: NavigationBarType1 = {
        let bar = NavigationBarType1(navigationTitle: "내 센터 정보")
        return bar
    }()
    
    let editingCompleteButton: TextButtonType3 = {
        let btn = TextButtonType3(typography: .Subtitle2)
        btn.textString = "저장"
        btn.attrTextColor = DSKitAsset.Colors.orange500.color
        return btn
    }()
    
    // View
    
    /// Center name label
    let centerNameLabel: IdleLabel = {
        let label = IdleLabel(typography: .Heading1)
        return label
    }()
    
    /// Center location label
    let centerLocationLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        
        return label
    }()
    
    /// ☑️ 센터 상세정보 ☑️
    let centerDetailLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body2)
        label.textString = "센터 상세 정보"
        return label
    }()
    let profileEditButton: TextButtonType2 = {
        let button = TextButtonType2(labelText: "수정하기")
        
        button.label.typography = .Body3
        button.label.attrTextColor = DSKitAsset.Colors.gray300.color
        button.layoutMargins = .init(top: 5.5, left:12, bottom: 5.5, right: 12)
        button.layer.cornerRadius = 16
        return button
    }()
    
    /// ☑️ "전화번호" 라벨 ☑️
    let centerPhoneNumeberTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "전화번호"
        label.textColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    /// 센터 전화번호가 표시되는 라벨
    let centerPhoneNumeberLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        return label
    }()
    /// 센터 전화번호를 편집할 수 있는 텍스트 필드
    let centerPhoneNumeberField: MultiLineTextField = {
        let textView = MultiLineTextField(
            typography: .Body3,
            placeholderText: "추가적으로 요구사항이 있다면 작성해주세요."
        )
        textView.textContainerInset = .init(top: 10, left: 16, bottom: 10, right: 24)
        textView.isScrollEnabled = false
        return textView
    }()
    
    /// ☑️ "센토 소개" 라벨 ☑️
    let centerIntroductionTitleLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "센터 소개"
        label.textColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    
    /// 센터 소개가 표시되는 라벨
    let centerIntroductionLabel: IdleLabel = {
        let label = IdleLabel(typography: .Body3)
        return label
    }()
    /// 센터 소개를 수정하는 텍스트 필드
    let centerIntroductionTextView: MultiLineTextField = {
        let textView = MultiLineTextField(
            typography: .Body3,
            placeholderText: "추가적으로 요구사항이 있다면 작성해주세요."
        )
        return textView
    }()
    
    /// ☑️ "센토 사진" 라벨 ☑️
    let centerPictureLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle4)
        label.textString = "센터 사진"
        label.textColor = DSKitAsset.Colors.gray500.color
        return label
    }()
    let centerImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        view.backgroundColor = DSKitAsset.Colors.gray100.color
        return view
    }()
    let centerImageEditButton: UIButton = {
        let btn = UIButton()
        btn.setImage(DSKitAsset.Icons.editPhoto.image, for: .normal)
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    let edtingImage: PublishRelay<UIImage> = .init()
    
    let disposeBag = DisposeBag()
    
    public init() {
        
        super.init(nibName: nil, bundle: nil)
        
        setApearance()
        setAutoLayout()
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func setApearance() {
        view.backgroundColor = .white
    }
    
    func setAutoLayout() {
        
        let navigationStack = HStack([
            navigationBar,
            editingCompleteButton,
        ])
        navigationStack.distribution = .equalSpacing
        navigationStack.backgroundColor = .white
        
        let navigationStackBackground = UIView()
        navigationStackBackground.addSubview(navigationStack)
        navigationStack.translatesAutoresizingMaskIntoConstraints = false
        navigationStackBackground.backgroundColor = .white
        navigationStackBackground.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 28)
        NSLayoutConstraint.activate([
            navigationStack.topAnchor.constraint(equalTo: navigationStackBackground.layoutMarginsGuide.topAnchor),
            navigationStack.leadingAnchor.constraint(equalTo: navigationStackBackground.layoutMarginsGuide.leadingAnchor),
            navigationStack.trailingAnchor.constraint(equalTo: navigationStackBackground.layoutMarginsGuide.trailingAnchor),
            navigationStack.bottomAnchor.constraint(equalTo: navigationStackBackground.layoutMarginsGuide.bottomAnchor),
        ])
        
        let locationIcon = UIImageView.locationMark
        
        let centerLocationStack = HStack(
            [
                locationIcon,
                centerLocationLabel
            ],
            spacing: 2,
            alignment: .center
        )
        
        let centerPhoneNumberStack = VStack(
            [
                centerPhoneNumeberTitleLabel,
                centerPhoneNumeberLabel,
                centerPhoneNumeberField,
            ],
            spacing: 6,
            alignment: .fill
        )
        
        let centerIntroductionStack = VStack(
            [
                centerIntroductionTitleLabel,
                centerIntroductionLabel,
                centerIntroductionTextView,
            ],
            spacing: 6,
            alignment: .fill
        )
        
        // 센터 이미지뷰 세팅
//        centerImageView.addSubview(centerImageEditButton)
//        centerImageEditButton.translatesAutoresizingMaskIntoConstraints = false
        
        let scrollView = UIScrollView()
        
        let divider = UIView()
        divider.backgroundColor = DSKitAsset.Colors.gray050.color
        
        [
            centerNameLabel,
            centerLocationStack,
            
            divider,
            
            centerDetailLabel,
            profileEditButton,
            
            centerPhoneNumberStack,
            
            centerIntroductionStack,
            
            centerPictureLabel,
            centerImageView,
            centerImageEditButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        [
            navigationStackBackground,
            scrollView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        // view 서브뷰 zindex설정
        navigationStackBackground.layer.zPosition = 1
        scrollView.layer.zPosition = 0
        
        // 전체 뷰
        NSLayoutConstraint.activate([
            navigationStackBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationStackBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationStackBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: navigationStackBackground.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 뷰 고정 사이즈
        NSLayoutConstraint.activate([
            locationIcon.widthAnchor.constraint(equalToConstant: 24),
            locationIcon.heightAnchor.constraint(equalTo: locationIcon.widthAnchor),
            
            centerImageEditButton.widthAnchor.constraint(equalToConstant: 28),
            centerImageEditButton.heightAnchor.constraint(equalTo: centerImageEditButton.widthAnchor),
            
            centerIntroductionTextView.heightAnchor.constraint(equalToConstant: 156),
        ])
        
        let contentGuide = scrollView.contentLayoutGuide
        scrollView.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        scrollView.delaysContentTouches = false
        
        // 스크롤 뷰의 서브뷰
        NSLayoutConstraint.activate([
            
            centerNameLabel.topAnchor.constraint(equalTo: contentGuide.topAnchor, constant: 25),
            centerNameLabel.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            
            centerLocationStack.topAnchor.constraint(equalTo: centerNameLabel.bottomAnchor, constant: 12),
            centerLocationStack.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            
            divider.topAnchor.constraint(equalTo: centerLocationStack.bottomAnchor, constant: 20),
            divider.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            divider.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            divider.heightAnchor.constraint(equalToConstant: 8),
            
            centerDetailLabel.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 24),
            centerDetailLabel.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            
            profileEditButton.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 24),
            profileEditButton.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            
            centerPhoneNumberStack.topAnchor.constraint(equalTo: centerDetailLabel.bottomAnchor, constant: 20),
            centerPhoneNumberStack.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            centerPhoneNumberStack.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            
            centerIntroductionStack.topAnchor.constraint(equalTo: centerPhoneNumberStack.bottomAnchor, constant: 20),
            centerIntroductionStack.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            centerIntroductionStack.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            
            centerPictureLabel.topAnchor.constraint(equalTo: centerIntroductionStack.bottomAnchor, constant: 20),
            centerPictureLabel.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            
            centerImageView.topAnchor.constraint(equalTo: centerPictureLabel.bottomAnchor, constant: 20),
            
            centerImageView.leadingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.leadingAnchor),
            centerImageView.trailingAnchor.constraint(equalTo: scrollView.layoutMarginsGuide.trailingAnchor),
            centerImageView.heightAnchor.constraint(equalToConstant: 250),
            centerImageView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -38),
            
            centerImageEditButton.trailingAnchor.constraint(equalTo: centerImageView.trailingAnchor, constant: -16),
            centerImageEditButton.bottomAnchor.constraint(equalTo: centerImageView.bottomAnchor, constant: -16),
        ])
    }
    
    func setObservable() {
        
        centerImageEditButton
            .rx.tap
            .subscribe { [weak self] _ in
                self?.showPhotoGalley()
            }
            .disposed(by: disposeBag)
    }
    
    public func bind(viewModel: any CenterProfileViewModelable) {
        
        self.viewModel = viewModel
        
        // input
        let input = viewModel.input
        
        profileEditButton
            .eventPublisher
            .bind(to: input.editingButtonPressed)
            .disposed(by: disposeBag)
        
        editingCompleteButton
            .eventPublisher
            .bind(to: input.editingFinishButtonPressed)
            .disposed(by: disposeBag)
        
        centerPhoneNumeberField.rx.text
            .compactMap { $0 }
            .bind(to: input.editingPhoneNumber)
            .disposed(by: disposeBag)
        
        centerIntroductionTextView.rx.text
            .compactMap { $0 }
            .bind(to: input.editingInstruction)
            .disposed(by: disposeBag)
        
        edtingImage
            .bind(to: input.editingImage)
            .disposed(by: disposeBag)
        
        // output
        guard let output = viewModel.output else { fatalError() }
        
        output
            .centerName
            .drive(centerNameLabel.rx.textString)
            .disposed(by: disposeBag)
        
        output
            .centerLocation
            .drive(centerLocationLabel.rx.textString)
            .disposed(by: disposeBag)
        
        output
            .centerPhoneNumber
            .drive(centerPhoneNumeberLabel.rx.textString)
            .disposed(by: disposeBag)
        output
            .centerPhoneNumber
            .drive(centerPhoneNumeberField.rx.textString)
            .disposed(by: disposeBag)
        
        output
            .centerIntroduction
            .drive(centerIntroductionLabel.rx.textString)
            .disposed(by: disposeBag)
        output
            .centerIntroduction
            .drive(centerIntroductionTextView.rx.textString)
            .disposed(by: disposeBag)
        
        output
            .centerImage
            .drive(centerImageView.rx.image)
            .disposed(by: disposeBag)
        
        // MARK: Edit Mode
        output
            .isEditingMode
            .map { !$0 }
            .drive(centerPhoneNumeberField.rx.isHidden)
            .disposed(by: disposeBag)
        output
            .isEditingMode
            .drive(centerPhoneNumeberLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output
            .isEditingMode
            .map { !$0 }
            .drive(centerIntroductionTextView.rx.isHidden)
            .disposed(by: disposeBag)
        output
            .isEditingMode
            .drive(centerIntroductionLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        output
            .isEditingMode
            .map { !$0 }
            .drive(centerImageEditButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        output
            .isEditingMode
            .map { !$0 }
            .drive(editingCompleteButton.rx.isHidden)
            .disposed(by: disposeBag)
        output
            .isEditingMode
            .drive(profileEditButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        output
            .alert
            .drive { [weak self] vo in
                self?.showAlert(vo: vo)
            }
            .disposed(by: disposeBag)
        
        output
            .editingValidation
            .drive { _ in
                // do something when editing success
            }
            .disposed(by: disposeBag)
        
        viewModel.requestData()
    }
    
    public func showAlert(vo: DefaultAlertContentVO) {
        let alret = UIAlertController(title: vo.title, message: vo.message, preferredStyle: .alert)
        let close = UIAlertAction(title: "닫기", style: .default, handler: nil)
        alret.addAction(close)
        present(alret, animated: true, completion: nil)
    }
    
    public func cleanUp() {
        
    }
}

extension CenterProfileViewController {
    
    func showPhotoGalley() {
        
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            return
        }
        
        imagePickerVC.sourceType = .photoLibrary
        
//        let modiaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)
        present(imagePickerVC, animated: true)
    }
}
    
extension CenterProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            edtingImage.accept(image)
            centerImageView.image = image
            
            picker.dismiss(animated: true)
        }
    }
}
