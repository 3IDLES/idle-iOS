//
//  OneLineIF.swift
//  DSKit
//
//  Created by choijunios on 7/5/24.
//

import UIKit
import RxSwift
import RxCocoa
import PresentationCore

public class IdleOneLineInputField: UIView {
    
    public var isEnabled: Bool = true
    
    // Init parameters
    var state: BehaviorSubject<State> = .init(value: .editing)
    let initialText: String
    public let normalBorderColor: UIColor
    
    public var eventPublisher: Observable<String> { textField.rx.text.compactMap { $0 }}
    
    // MARK: TextField
    public private(set) lazy var textField: IdleTextField = {
        let view = IdleTextField(typography: .Body3)
        return view
    }()
    
    // MARK: Clear button
    private lazy var clearButton: UIButton = {
       
        let button = UIButton()
        
        let image = DSKitAsset.Icons.tfClear.image
        button.setImage(image, for: .normal)
        
        button.imageView?.contentMode = .scaleAspectFit
        button.imageView?.clipsToBounds = true
        
        return button
    }()
    // 사라질 수 있는 뷰의 오토 레이아웃을 관리
    private var clearButtonHeightConstraint: NSLayoutConstraint!
    
    // MARK: Complete image
    public var isCompleteImageAvailable: Bool
    
    private let completeImage: UIImageView = {
       
        let image = DSKitAsset.Icons.tfCheck.image
        
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        
        return view
    }()
    // 사라질 수 있는 뷰의 오토 레이아웃을 관리
    private var completeImageHeightConstraint: NSLayoutConstraint!
    
    // MARK: Timer label
    private var timerLabel: TimerLabel?
    private var timer: Timer?
    
    private let stack: UIStackView = {
        
        let stack = UIStackView()
        
        stack.axis = .horizontal
        stack.alignment = .fill
        
        return stack
    }()
    
    public let disposeBag = DisposeBag()
    
    public var movingView: UIView?
    
    public init(
        state: State = .editing,
        initialText: String = "",
        placeHolderText: String,
        keyboardType: UIKeyboardType = .default,
        isCompleteImageAvailable: Bool = true,
        borderColor: UIColor = DSKitAsset.Colors.gray100.color
    ) {
        self.initialText = initialText
        self.isCompleteImageAvailable = isCompleteImageAvailable
        self.normalBorderColor = borderColor
        
        super.init(frame: .zero)
        
        self.layoutMargins = .init(top: 0, left: 0, bottom: 0, right: 20)
        
        // Border
        self.layer.cornerRadius = 6
        self.layer.borderWidth = 1
        self.layer.borderColor = borderColor.cgColor
        
        // Initial setting
        textField.placeholder = placeHolderText
        textField.keyboardType = keyboardType
        textField.contentVerticalAlignment = .center
        
        completeImage.isHidden = true
        
        if initialText.isEmpty {
            
            clearButton.isHidden = true
        }
        
        setAutoLayout()
        
        setObserver()
        
        self.state.onNext(state)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    private func setAutoLayout() {
        
        [
            stack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview($0)
        }
        
        [
            textField,
            clearButton,
            completeImage,
        ].forEach {
            stack.addArrangedSubview($0)
        }
        
        textField.setContentHuggingPriority(.init(750), for: .horizontal)
        clearButton.setContentHuggingPriority(.init(751), for: .horizontal)
        completeImage.setContentHuggingPriority(.init(751), for: .horizontal)
        
        textField.setContentCompressionResistancePriority(.init(750), for: .horizontal)
        clearButton.setContentCompressionResistancePriority(.init(751), for: .horizontal)
        completeImage.setContentCompressionResistancePriority(.init(751), for: .horizontal)
        
        NSLayoutConstraint.activate([
        
            stack.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
        ])
    }
    
    public override func resignFirstResponder() -> Bool {
        
        textField.resignFirstResponder()
        
        return super.resignFirstResponder()
    }
    
    public func setObserver() {
        
        let isEmpty = textField.rx.text
            .orEmpty
            .map { $0.isEmpty }
        
        let clearButtonEnable = Observable
            .combineLatest(isEmpty, state)
            .map({ (lhs, rhs) in
                // 문자열이 비지 않음 && editing모드인 경우
                !lhs && (rhs == .editing)
            })
        
        clearButtonEnable
            .map({ !$0 })
            .bind(to: clearButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        let completeImageEnable = state
            .map { [weak self] in $0 == .complete && self?.isCompleteImageAvailable ?? false }
        
        completeImageEnable
            .map({ !$0 })
            .bind(to: completeImage.rx.isHidden)
            .disposed(by: disposeBag)
        
        clearButton
            .rx.tap.subscribe { [weak self] _ in
                
                self?.textField.text = ""
                self?.textField.sendActions(for: .editingChanged)
                self?.clearButton.isHidden = true
            }
            .disposed(by: disposeBag)
    }
}

// MARK: TextField Focusing
public extension IdleOneLineInputField {
    
    enum State {
        
        case editing
        case complete
    }
    
    func setState(state: State) { self.state.onNext(state) }
    
    private func onFocused() {
        
        self.layer.borderColor = DSKitAsset.Colors.gray700.color.cgColor
    }
    
    private func onResignFocused() {
        
        self.layer.borderColor = DSKitAsset.Colors.gray100.color.cgColor
    }
    
    @MainActor
    func onCustomState(changingClosure: (IdleOneLineInputField) -> Void) {
        changingClosure(self)
    }
}

extension IdleOneLineInputField: UITextFieldDelegate {
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        
        // FirstResponder해제
        onResignFocused()
    }
    
    // 텍스트필드가 FirstReponder가 된 경우 호출
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // Focus apearance
        onFocused()
        
        // 에디팅 시작, 완료상태 해제
        state.onNext(.editing)
        
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // 에디팅 시작, 완료상태 해제
        state.onNext(.editing)
        
        return true
    }
}

// MARK: 활성상태
extension IdleOneLineInputField: DisablableComponent {
    
    public func setEnabled(_ isEnabled: Bool) {
        self.isEnabled = isEnabled
        self.isUserInteractionEnabled = isEnabled
        
        textField.textColor = isEnabled ? .black : DSKitAsset.Colors.gray300.color
        self.backgroundColor = isEnabled ? .white : DSKitAsset.Colors.gray050.color
        
        if let timerLabel {
            
            timerLabel.textColor = isEnabled ? timerLabel.originTextColor : timerLabel.disabledTextColor
        }
        
        if !isEnabled {
            
            onResignFocused()
        }
    }
}

// MARK: Timer
public extension IdleOneLineInputField {
    
    class TimerLabel: ResizableUILabel {
        
        let originTextColor = DSKitAsset.Colors.gray500.color
        let disabledTextColor = DSKitAsset.Colors.gray200.color
        
        func setTime(seconds: Int) {
            
            let minute = seconds / 60
            let second = seconds % 60
            
            let minuteText = minute < 10 ? "0\(minute)" : "\(minute)"
            let secondText = second < 10 ? "0\(second)" : "\(second)"
            
            self.text = "\(minuteText):\(secondText)"
        }
    }
    
    // Creation
    func createTimer() {
        
        // 중복생성 방지
        if timerLabel != nil { return }
        
        let timerLabel = TimerLabel()
        timerLabel.setTime(seconds: 0)
        timerLabel.font = DSKitFontFamily.Pretendard.medium.font(size: 14)
        timerLabel.textColor = DSKitAsset.Colors.gray500.color
        timerLabel.textAlignment = .center
        
        stack.addArrangedSubview(timerLabel)
        timerLabel.setContentHuggingPriority(.init(751), for: .horizontal)
        timerLabel.setContentCompressionResistancePriority(.init(751), for: .horizontal)
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            timerLabel.heightAnchor.constraint(equalTo: textField.heightAnchor),
        ])
        
        self.timerLabel = timerLabel
    }
    
    func removeTimer() {
        
        if let timerLabel = stack.arrangedSubviews.first(where: { ($0 as? TimerLabel) != nil }) {
            // timer라벨이 존재하는 경우 삭제
            stopTimer()
            // Consraints비활성화 후 삭제해야한다.
            timerLabel.constraints.forEach { $0.isActive = false }
            stack.removeArrangedSubview(timerLabel)
        }
    }
    
    // Management
    func startTimer(minute: Int, seconds: Int) {
        
        if let timerLabel, timer == nil {
            
            var startSeconds = minute * 60 + seconds
            
            timerLabel.setTime(seconds: startSeconds)
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                
                startSeconds -= 1
                
                if startSeconds == 0 {
                    
                    self?.stopTimer()
                    
                    return
                }
                
                self?.timerLabel?.setTime(seconds: startSeconds)
            }
        }
    }
    
    func stopTimer() {
                
        timer?.invalidate()
        timer = nil
    }
    
    // Visibility
    func showTimer() {
        
        timerLabel?.isHidden = false
    }
    
    func dismissTimer() {
        
        timerLabel?.isHidden = true
    }
}

extension IdleOneLineInputField: IdleKeyboardAvoidable { }
