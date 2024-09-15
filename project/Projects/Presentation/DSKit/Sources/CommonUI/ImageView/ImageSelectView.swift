//
//  ImageSelectView.swift
//  DSKit
//
//  Created by choijunios on 7/26/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

public class ImageSelectView: UIImageView {
    
    public enum State {
        case editing
        case normal
    }
    
    // Init
    public private(set) var state: BehaviorRelay<State>
    
    public weak var viewController: UIViewController!
    
    // Optinal values
    public var onError: (()->())?
    
    // image
    public private(set) var displayingImage: BehaviorRelay<UIImage?> = .init(value: nil)
    public private(set) var selectedImage: BehaviorRelay<UIImage?> = .init(value: nil)
    
    public init(state: State, viewController: UIViewController) {
        self.state = .init(value: state)
        self.viewController = viewController
        super.init(frame: .zero)
        
        setAppearacne()
        setLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    // View
    /// PlaceHolderView(Edit)
    let placeholderViewForEdit: TappableUIView = {
        let view = TappableUIView()
        view.backgroundColor = DSKitAsset.Colors.gray100.color
        let imageView = DSKitAsset.Icons.camera.image.toView()
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints=false
        imageView.tintColor = .white
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 54),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        return view
    }()
    
    /// PlaceHolderView(Normal)
    let placeholderViewForNormal: UIView = {
        let view = UIView()
        view.backgroundColor = DSKitAsset.Colors.gray050.color
        let imageView = DSKitAsset.Icons.picture.image.toView()
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints=false
        imageView.tintColor = DSKitAsset.Colors.gray100.color
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 38),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        return view
    }()
    
    /// Edit ButtonView
    let centerImageEditButton: UIButton = {
        let btn = UIButton()
        btn.setImage(DSKitAsset.Icons.editPhoto.image, for: .normal)
        btn.isUserInteractionEnabled = true
        return btn
    }()
    
    private let disposeBag = DisposeBag()
    
    private func setAppearacne() {
        
        self.isUserInteractionEnabled = true
        
        self.layer.cornerRadius = 6
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
    }
    
    private func setLayout() {
        
        [
            placeholderViewForEdit,
            placeholderViewForNormal,
            centerImageEditButton
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            placeholderViewForEdit.topAnchor.constraint(equalTo: self.topAnchor),
            placeholderViewForEdit.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeholderViewForEdit.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            placeholderViewForEdit.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            placeholderViewForNormal.topAnchor.constraint(equalTo: self.topAnchor),
            placeholderViewForNormal.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            placeholderViewForNormal.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            placeholderViewForNormal.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            centerImageEditButton.widthAnchor.constraint(equalToConstant: 28),
            centerImageEditButton.heightAnchor.constraint(equalTo: centerImageEditButton.widthAnchor),
            
            centerImageEditButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            centerImageEditButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16),
        ])
        
    }
    
    private func setObservable() {
        
        Observable
            .combineLatest(
                displayingImage,
                state
            )
            .subscribe(onNext: { [weak self] (image, state) in
                
                guard let self else { return }
                
                if image != nil {
                    self.image = image
                    placeholderViewForEdit.isHidden = true
                    placeholderViewForNormal.isHidden = true
                    centerImageEditButton.isHidden = state == .normal
                } else {
                    placeholderViewForEdit.isHidden = state == .normal
                    placeholderViewForNormal.isHidden = state == .editing
                    centerImageEditButton.isHidden = true
                }
            })
            .disposed(by: disposeBag)
        
        Observable
            .merge(
                placeholderViewForEdit.rx.tap.asObservable(),
                centerImageEditButton.rx.tap.asObservable()
            )
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [unowned self] in
                showPhotoGalley()
            })
            .disposed(by: disposeBag)
    }
}

extension ImageSelectView: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private func showPhotoGalley() {
        
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        
        if !UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            onError?()
            return
        }
        
        imagePickerVC.sourceType = .photoLibrary
        viewController.present(imagePickerVC, animated: true)
    }
        
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            // image
            selectedImage.accept(image)
            
            picker.dismiss(animated: true)
        }
    }
}



