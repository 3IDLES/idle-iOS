//
//  ExpPicker.swift
//  DSKit
//
//  Created by choijunios on 8/10/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity
import PresentationCore
import FSCalendar

public class ExpPicker: TextImageButtonType2 {
    
    static let maxExp = 20
    
    private let pickerData: [String] = (0...ExpPicker.maxExp).map { exp in
        switch exp {
        case 0:
            "신입"
        case 1...ExpPicker.maxExp:
            "\(exp)년차"
        default:
            fatalError()
        }
    }
    
    public lazy var pickedExp: PublishRelay<Int> = .init()
    public private(set) var currentExp: Int?
    
    // View
    public lazy var pickerView: UIPickerView = {
        let view = UIPickerView()
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private let disposeBag = DisposeBag()
    
    public override var inputView: UIView? {
        pickerView
    }
    
    public override var inputAccessoryView: UIView? {
        let toolbar = UIToolbar()
        toolbar.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: 40)
        
        let space = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let doneButton = UIBarButtonItem(
            title: "닫기",
            style: .done,
            target: self,
            action: #selector(didTapDone(_:))
        )
        
        doneButton.tintColor = DSKitAsset.Colors.gray900.color
        let items = [space, doneButton]
        toolbar.setItems(items, animated: false)
        toolbar.sizeToFit()
        
        return toolbar
    }
    
    public var placeholderText: String {
        get {
            textLabel.textString
        }
        set {
            textLabel.textString = newValue
        }
    }
    
    public override var canBecomeFirstResponder: Bool { true }
    
    public init(placeholderText: String) {
        super.init()
        
        textLabel.textString = placeholderText
        
        // 초기값 설정
        currentExp = 0
        
        setObservable()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setObservable() {
        self.rx.tap
            .subscribe { [weak self] _ in
                self?.didTapButton()
            }
            .disposed(by: disposeBag)
    }
}

@objc
extension ExpPicker {
    /// Close the picker view
    private func didTapClose(_ button: UIBarButtonItem) {
        resignFirstResponder()
    }
    
    private func didTapDone(_ button: UIBarButtonItem) {
        
        
        
        resignFirstResponder()
    }
    
    //MARK: - Open the picker view
    private func didTapButton() {
        printIfDebug("CustomPickerButton: button Tap")
        becomeFirstResponder()
    }
    
}

extension ExpPicker : UIPickerViewDataSource, UIPickerViewDelegate {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    //data 선택시 동작할 event
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // 라벨 변경
        textLabel.textString = pickerData[row]
        
        // row = 경력연차
        pickedExp.accept(row)
    }
}
