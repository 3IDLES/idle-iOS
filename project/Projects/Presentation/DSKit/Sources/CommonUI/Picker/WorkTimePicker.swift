//
//  IdlePickerView.swift
//  DSKit
//
//  Created by choijunios on 8/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity
import PresentationCore

/// 오전/오후, 시, 분을 나타냅니다.
public struct DateComponent {
    var part: String
    var hour: String
    var minute: String
    
    public var toString: String {
        "\(part) \(hour):\(minute)"
    }
    
    init(part: String, hour: String, minute: String) {
        self.part = part
        self.hour = hour
        self.minute = minute
    }
}

public class WorkTimePicker: TextImageButtonType2 {
    
    private let pickerData: [Int: [String]] = [
        0: ["오전", "오후"],
        1: (1...12).map { $0 < 10 ? "0\($0)" : "\($0)" },
        2: (0...5).map { $0 == 0 ? "00" : "\($0 * 10)" }
    ]
    
    public lazy var pickedDateString: PublishRelay<DateComponent> = .init()
    public private(set) var currentDateComponent: DateComponent?
    
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
        
        let closeButton = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(didTapClose(_:))
        )
        closeButton.tintColor = DSKitAsset.Colors.gray900.color
        
        let space = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        let doneButton = UIBarButtonItem(
            title: "저장",
            style: .done,
            target: self,
            action: #selector(didTapDone(_:))
        )
        
        doneButton.tintColor = DSKitAsset.Colors.gray900.color
        let items = [closeButton, space, doneButton]
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
        currentDateComponent = .init(
            part: pickerData[0]!.first!,
            hour: pickerData[1]!.first!,
            minute: pickerData[2]!.first!
        )
        
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
extension WorkTimePicker {
    /// Close the picker view
    private func didTapClose(_ button: UIBarButtonItem) {
        resignFirstResponder()
    }
    
    private func didTapDone(_ button: UIBarButtonItem) {
        
        // 라벨 변경
        if let component = currentDateComponent {
            textLabel.textString = component.toString
            pickedDateString.accept(component)
        }
        
        resignFirstResponder()
    }
    
    //MARK: - Open the picker view
    private func didTapButton() {
        printIfDebug("CustomPickerButton: button Tap")
        becomeFirstResponder()
    }
    
}

extension WorkTimePicker : UIPickerViewDataSource, UIPickerViewDelegate {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component]!.count
    }
    
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[component]?[row]
    }
    
    //data 선택시 동작할 event
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
        case 0:
            currentDateComponent?.part = pickerData[component]![row]
        case 1:
            currentDateComponent?.hour = pickerData[component]![row]
        case 2:
            currentDateComponent?.minute = pickerData[component]![row]
        default:
            fatalError()
        }
    }
}
