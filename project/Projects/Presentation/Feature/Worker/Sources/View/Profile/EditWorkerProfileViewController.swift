//
//  EditWorkerProfileViewController.swift
//  WorkerFeature
//
//  Created by choijunios on 7/22/24.
//

import UIKit
import PresentationCore
import RxSwift
import RxCocoa
import DSKit
import Entity
import BaseFeature

public class EditWorkerProfileViewController: BaseViewController {
    
    // Navigation bar
    let navigationBar: NavigationBarType1 = {
        let bar = NavigationBarType1(navigationTitle: "내 프로필")
        return bar
    }()
    
    let editingCompleteButton: TextButtonType3 = {
        let btn = TextButtonType3(typography: .Subtitle2)
        btn.textString = "저장"
        btn.attrTextColor = DSKitAsset.Colors.orange500.color
        
        return btn
    }()
    
    // 프로필 이미지
    let profileImageContainer: UIImageView = {
        
        let view = UIImageView()
        view.backgroundColor = DSKitAsset.Colors.orange100.color
        view.layer.cornerRadius = 48
        view.clipsToBounds = true
        view.image = DSKitAsset.Icons.workerProfilePlaceholder.image
        view.contentMode = .scaleAspectFit

        return view
    }()
    let workerProfileImage: UIImageView = {
        
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 48
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let workerProfileImageEditButton: UIButton = {
        let btn = UIButton()
        btn.setImage(DSKitAsset.Icons.editPhoto.image, for: .normal)
        btn.imageView?.layer.borderColor = DSKitAsset.Colors.gray050.color.cgColor
        btn.imageView?.layer.cornerRadius = 16
        btn.imageView?.layer.borderWidth = 1
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    // 상태 선택 버튼
    let jobFindingState = SlideStateButton.State.state2
    let restingState = SlideStateButton.State.state1
    let stateSelectButton: SlideStateButton = {
        let button: SlideStateButton = .init(initialState: .state1)
        button.state1Label.textString = "휴식중"
        button.state2Label.textString = "구인중"
        return button
    }()
    
    // 이름, 나이, 성별, 전화번호
    let nameLabel: IdleLabel = .init(typography: .Subtitle1)
    let ageLabel: IdleLabel = .init(typography: .Body3)
    let genderLabel: IdleLabel = .init(typography: .Body3)
    let phoneNumberLabel: IdleLabel = .init(typography: .Body3)
    
    // 경력
    let addtionalInfoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let experiencedSelectButton: ExpPicker = {
        let button = ExpPicker(placeholderText: "연차")
        
        button.textLabel.attrTextColor = DSKitAsset.Colors.gray500.color
        button.imageView.image = DSKitAsset.Icons.chevronDown.image
        button.imageView.tintColor = DSKitAsset.Colors.gray200.color
        
        return button
    }()
    
    // 주소
    private let addressSearchButton: TextButtonType2 = {
        let button = TextButtonType2(labelText: "")
        button.label.attrTextColor = DSKitAsset.Colors.gray900.color
        return button
    }()
    
    // 한줄소개
    let introductionInputField: MultiLineTextField = {
        let textView = MultiLineTextField(
            typography: .Body3,
            placeholderText: "소개"
        )
        textView.isScrollEnabled = false
        return textView
    }()
    
    // 특기
    let abilityInputField: MultiLineTextField = {
        let textView = MultiLineTextField(
            typography: .Body3,
            placeholderText: "특기"
        )
        textView.isScrollEnabled = false
        return textView
    }()
    
    let addressPublisher: PublishRelay<AddressInformation> = .init()
    let imagePublisher: PublishRelay<UIImage> = .init()
    
    // Optinal values
    public var onError: (()->())?
    
    public init() {
        
        super.init(nibName: nil, bundle: nil)
        
        setApearance()
        setAutoLayout()
        setObservable()
        setKeyboardAvoidance()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    private func setApearance() {
        view.backgroundColor = .white
        view.layoutMargins = .init(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
    }
    
    private func setAutoLayout() {
        
        // 네비게이션 바
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
        
        // 프로필 뷰
        
        // 유저의 입력으로 설정되는 사진을 표시하는 ImageView설정
        profileImageContainer.addSubview(workerProfileImage)
        workerProfileImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            workerProfileImage.topAnchor.constraint(equalTo: profileImageContainer.topAnchor),
            workerProfileImage.leadingAnchor.constraint(equalTo: profileImageContainer.leadingAnchor),
            workerProfileImage.trailingAnchor.constraint(equalTo: profileImageContainer.trailingAnchor),
            workerProfileImage.bottomAnchor.constraint(equalTo: profileImageContainer.bottomAnchor),
        ])
        
        let profileContainer = UIView()
        [
            profileImageContainer,
            workerProfileImageEditButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            profileContainer.addSubview($0)
        }
        NSLayoutConstraint.activate([
            profileImageContainer.widthAnchor.constraint(equalToConstant: 96),
            profileImageContainer.heightAnchor.constraint(equalTo: profileImageContainer.widthAnchor),
            
            profileImageContainer.topAnchor.constraint(equalTo: profileContainer.topAnchor),
            profileImageContainer.leadingAnchor.constraint(equalTo: profileContainer.leadingAnchor),
            profileImageContainer.trailingAnchor.constraint(equalTo: profileContainer.trailingAnchor),
            profileImageContainer.bottomAnchor.constraint(equalTo: profileContainer.bottomAnchor),
            
            workerProfileImageEditButton.widthAnchor.constraint(equalToConstant: 32),
            workerProfileImageEditButton.heightAnchor.constraint(equalTo: workerProfileImageEditButton.widthAnchor),
            
            workerProfileImageEditButton.bottomAnchor.constraint(equalTo: profileContainer.bottomAnchor),
            workerProfileImageEditButton.trailingAnchor.constraint(equalTo: profileContainer.trailingAnchor, constant: 7),
        ])
        
        // 나이, 성별, 전화번호 컨테이너
        let infoStack_divider1 = UIView()
        infoStack_divider1.backgroundColor = DSKitAsset.Colors.gray050.color
        let infoStack_divider2 = UIView()
        infoStack_divider2.backgroundColor = DSKitAsset.Colors.gray050.color
        
        let infoStackViews = [
            ("나이", ageLabel),
            ("성별", genderLabel),
            ("전화번호", phoneNumberLabel),
        ].map({ (title, labelView) in
            
            let titleLabel = IdleLabel(typography: .Body3)
            titleLabel.textString = title
            titleLabel.attrTextColor = DSKitAsset.Colors.gray500.color
            
            return HStack([
                titleLabel,
                labelView
            ], spacing: 4)
        })
        
        let infoStack = HStack(
            [
                infoStackViews[0],
                infoStack_divider1,
                infoStackViews[1],
                infoStack_divider2,
                infoStackViews[2],
            ],
            spacing: 8
        )
        
        NSLayoutConstraint.activate([
            infoStack_divider1.widthAnchor.constraint(equalToConstant: 1),
            infoStack_divider1.topAnchor.constraint(equalTo: infoStack.topAnchor, constant: 2),
            infoStack_divider1.bottomAnchor.constraint(equalTo: infoStack.bottomAnchor, constant: -2),
            
            infoStack_divider2.widthAnchor.constraint(equalToConstant: 1),
            infoStack_divider2.topAnchor.constraint(equalTo: infoStack.topAnchor, constant: 2),
            infoStack_divider2.bottomAnchor.constraint(equalTo: infoStack.bottomAnchor, constant: -2),
        ])
        
        let viewList = [
            profileContainer,
            Spacer(height: 12),
            nameLabel,
            Spacer(height: 6),
            stateSelectButton,
            Spacer(height: 16),
            infoStack,
        ]
        
        let profileAndInfoStack = VStack(
            viewList,
            spacing: 0,
            alignment: .center
        )
        
        // 경력, 주소, 한줄소개, 특기
        addtionalInfoView.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        
        let addtionalInfoStack = VStack(
            [
                ("경력", experiencedSelectButton),
                ("주소", addressSearchButton),
                ("한줄 소개", introductionInputField),
                ("특기", abilityInputField),
            ].map { (title, content) in
                VStack(
                    [
                        {
                            let label = IdleLabel(typography: .Subtitle4)
                            label.textString = title
                            label.attrTextColor = DSKitAsset.Colors.gray300.color
                            label.textAlignment = .left
                            return label
                        }(),
                        content
                    ],
                    spacing: 6,
                    alignment: .fill
                )
            },
            spacing: 28,
            alignment: .fill
        )
        
        [
            addtionalInfoStack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addtionalInfoView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            addtionalInfoStack.topAnchor.constraint(equalTo: addtionalInfoView.layoutMarginsGuide.topAnchor),
            addtionalInfoStack.leftAnchor.constraint(equalTo: addtionalInfoView.layoutMarginsGuide.leftAnchor),
            addtionalInfoStack.rightAnchor.constraint(equalTo: addtionalInfoView.layoutMarginsGuide.rightAnchor),
            addtionalInfoStack.bottomAnchor.constraint(equalTo: addtionalInfoView.layoutMarginsGuide.bottomAnchor),
            
            abilityInputField.heightAnchor.constraint(equalToConstant: 156),
        ])
        
        // 컨트롤러 뷰 설정
        let scrollView = UIScrollView()
        scrollView.delaysContentTouches = false
        scrollView.contentInset = .init(top: 39, left: 0, bottom: 66, right: 0)
        
        let contentGuide = scrollView.contentLayoutGuide
        let frameGuide = scrollView.frameLayoutGuide
        
        
        
        let divier = UIView()
        divier.backgroundColor = DSKitAsset.Colors.gray050.color
        
        let contentView = VStack([profileAndInfoStack, divier, addtionalInfoView], spacing: 20, alignment: .fill)
        
        [
            contentView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            scrollView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            divier.heightAnchor.constraint(equalToConstant: 8),
            
            contentView.widthAnchor.constraint(equalTo: frameGuide.widthAnchor),
            
            contentView.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            contentView.leftAnchor.constraint(equalTo: contentGuide.leftAnchor),
            contentView.rightAnchor.constraint(equalTo: contentGuide.rightAnchor),
            contentView.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
        ])
        
        
        [
            navigationStackBackground,
            scrollView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationStackBackground.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 21),
            navigationStackBackground.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navigationStackBackground.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            scrollView.topAnchor.constraint(equalTo: navigationStackBackground.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setObservable() {
        
        navigationBar
            .eventPublisher
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        workerProfileImageEditButton
            .rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.showPhotoGalley()
            })
            .disposed(by: disposeBag)
        
        addressSearchButton
            .eventPublisher
            .subscribe { [weak self] _ in
                self?.showDaumSearchView()
            }
            .disposed(by: disposeBag)
    }
    
    func bind(viewModel: WorkerProfileEditViewModelable) {
        
        // RO
        viewModel
            .profileRenderObject?
            .drive(onNext: { [weak self] ro in
                
                guard let self else { return }
                
                // UI 업데이트
                navigationBar.navigationTitle = ro.navigationTitle
                stateSelectButton.setState(ro.isJobFinding ? jobFindingState : restingState)
                nameLabel.textString = ro.nameText
                phoneNumberLabel.textString = ro.phoneNumber
                ageLabel.textString = ro.ageText
                genderLabel.textString = ro.genderText
                experiencedSelectButton.textLabel.textString = ro.expText
                addressSearchButton.label.textString = ro.address
                introductionInputField.textString = ro.oneLineIntroduce
                abilityInputField.textString = ro.specialty
            })
            .disposed(by: disposeBag)
        
        viewModel
            .displayingImage?
            .drive(onNext: { [weak self] image in
                guard let self else { return }
                UIView.transition(with: view, duration: 0.2) {
                    self.workerProfileImage .image = image
                }
            })
            .disposed(by: disposeBag)
        
        // 수정 실패 수신
        viewModel
            .alert?
            .drive(onNext: { [weak self] vo in
                self?.showAlert(vo: vo) { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        // 수정 성공 여부 수신
        viewModel
            .uploadSuccess?
            .drive(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
        
        // Input
        // 프로필 사진
        imagePublisher
            .bind(to: viewModel.editingImage)
            .disposed(by: disposeBag)
        
        // 상태
        stateSelectButton
            .stateObservable
            .map { [jobFindingState] state in
                state == jobFindingState
            }
            .asObservable()
            .bind(to: viewModel.editingIsJobFinding)
            .disposed(by: disposeBag)
            
        // 경력
        experiencedSelectButton
            .pickedExp
            .bind(to: viewModel.editingExpYear)
            .disposed(by: disposeBag)
        
        // 주소
        addressPublisher
            .bind(to: viewModel.editingAddress)
            .disposed(by: disposeBag)
        
        // 한줄 소개
        introductionInputField
            .rx.text
            .compactMap { $0 }
            .bind(to: viewModel.editingIntroduce)
            .disposed(by: disposeBag)
        
        // 특기
        abilityInputField
            .rx.text
            .compactMap { $0 }
            .bind(to: viewModel.editingSpecialty)
            .disposed(by: disposeBag)

        // 업로드 요청
        editingCompleteButton
            .eventPublisher
            .bind(to: viewModel.requestUpload)
            .disposed(by: disposeBag)
    }
    
    func setKeyboardAvoidance() {
        
         [
            introductionInputField.setKeyboardAvoidance,
            abilityInputField.setKeyboardAvoidance,
         ].forEach { setFunc in
             setFunc(addtionalInfoView)
         }
    }
}

// MARK: 주소설정
extension EditWorkerProfileViewController: DaumAddressSearchDelegate {
    
    private func showDaumSearchView() {
        let vc = DaumAddressSearchViewController()
        vc.delegate = self
        navigationController?.pushViewController(vc, animated: true)
    }
    
    public func addressSearch(addressData: [AddressDataKey : String]) {
        
        let jibunAddress = addressData[.jibunAddress]!
        let roadAddress = addressData[.roadAddress]!
        let autoJibunAddress = addressData[.autoJibunAddress]!
        let autoRoadAddress = addressData[.autoRoadAddress]!
        
        let finalJibunAddress = jibunAddress.isEmpty ? autoJibunAddress : jibunAddress
        let finalRoadAddress = roadAddress.isEmpty ? autoRoadAddress : roadAddress
        
        addressSearchButton.label.textString = finalRoadAddress
        
        addressPublisher.accept(
            AddressInformation(
                roadAddress: finalRoadAddress,
                jibunAddress: finalJibunAddress
            )
        )
    }
}

// MARK: 사진 선택
extension EditWorkerProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func showPhotoGalley() {
        
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            onError?()
            return
        }
        
        imagePickerVC.sourceType = .photoLibrary
        self.present(imagePickerVC, animated: true)
    }
        
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
        if 
            let imageUrl = info[UIImagePickerController.InfoKey.imageURL] as? URL,
            let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
                        
            workerProfileImage.setImage(url: imageUrl)
            imagePublisher.accept(image)
            
            picker.dismiss(animated: true)
        }
    }
}
