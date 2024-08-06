//
//  OneDayPicker.swift
//  DSKit
//
//  Created by choijunios on 8/2/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity
import PresentationCore
import FSCalendar

public protocol OneDayPickerDelegate: NSObject {
    
    func oneDayPicker(selectedDate: Date)
}

public class OneDayPickerViewController: UIViewController {
    
    // Not init
    private var gestureBeganPosition: CGPoint = .zero
    private var lastGesturePosition: CGPoint = .zero
    
    // View
    public let calendar = FSCalendar()
    
    let calendarInputView = UIView()
    
    let dragSpace: UIView = {
        let bar = UIView()
        bar.backgroundColor = DSKitAsset.Colors.gray200.color
        bar.layer.cornerRadius = 2
        
        let space = UIView()
        
        space.addSubview(bar)
        bar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            bar.heightAnchor.constraint(equalToConstant: 4),
            bar.widthAnchor.constraint(equalToConstant: 55),
            bar.centerXAnchor.constraint(equalTo: space.centerXAnchor),
            bar.topAnchor.constraint(equalTo: space.topAnchor, constant: 13),
            bar.bottomAnchor.constraint(equalTo: space.bottomAnchor, constant: -19),
        ])
        
        return space
    }()
    
    public weak var delegate: OneDayPickerDelegate?
    
    public init() {
        
        super.init(nibName: nil, bundle: nil)
        configureCalendar()
        setObservable()
        setGesture()
    }
    
    
    required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        
        setAppearance()
        setLayout()
    }
    
    private func setAppearance() {
        
        view.backgroundColor = .black.withAlphaComponent(0.0)
    }
    
    private func setLayout() {
        
        let conerRadius = 16.0
        
        calendarInputView.backgroundColor = .white
        calendarInputView.layer.cornerRadius = conerRadius
        calendarInputView.layoutMargins = .init(top: 0, left: 27, bottom: 64 + conerRadius, right: 27)
        
        let label = IdleLabel(typography: .Heading3)
        label.textString = "접수 마감일"
        label.textAlignment = .center
        
        let stack = VStack(
            [
                label,
                calendar
            ],
            spacing: 31,
            alignment: .fill
        )
        
        [
            dragSpace,
            stack
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            calendarInputView.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            
            dragSpace.topAnchor.constraint(equalTo: calendarInputView.layoutMarginsGuide.topAnchor),
            dragSpace.leftAnchor.constraint(equalTo: calendarInputView.leftAnchor),
            dragSpace.rightAnchor.constraint(equalTo: calendarInputView.rightAnchor),
            
            calendar.heightAnchor.constraint(equalToConstant: 320),
            
            stack.topAnchor.constraint(equalTo: dragSpace.bottomAnchor),
            stack.leftAnchor.constraint(equalTo: calendarInputView.layoutMarginsGuide.leftAnchor),
            stack.rightAnchor.constraint(equalTo: calendarInputView.layoutMarginsGuide.rightAnchor),
            stack.bottomAnchor.constraint(equalTo: calendarInputView.layoutMarginsGuide.bottomAnchor),
        ])
        
        [
            calendarInputView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            calendarInputView.rightAnchor.constraint(equalTo: view.rightAnchor),
            calendarInputView.leftAnchor.constraint(equalTo: view.leftAnchor),
            calendarInputView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: conerRadius)
        ])
    }
    
    private func setObservable() {
        
        
    }
    
    private func configureCalendar() {
        
        calendar.delegate = self
        calendar.dataSource = self
            
        // 주간 월간 선택
        calendar.scope = .month
        
        // Locale설정
        calendar.locale = Locale(identifier: "ko_KR")
         
        // 스크롤 여부
        calendar.scrollEnabled = true
        calendar.scrollDirection = .horizontal
        
        
        // 헤더 설정
        calendar.appearance.headerTitleFont = DSKitFontFamily.Pretendard.semiBold.font(size: 18)
        calendar.appearance.headerTitleColor = DSKitAsset.Colors.gray900.color
        
        calendar.appearance.headerDateFormat = "YYYY년 MM월"
        calendar.appearance.headerTitleAlignment = .center
        calendar.headerHeight = 56
        calendar.appearance.headerTitleOffset = .init(x: 0, y: -28+15)
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0   // 0.0 = 안보이게 됩니다.
        
        // Weekday 폰트 설정
        calendar.appearance.weekdayFont = DSKitFontFamily.Pretendard.semiBold.font(size: 14)
        calendar.appearance.weekdayTextColor = DSKitAsset.Colors.gray300.color
        
        // 각각의 일(날짜) 폰트 설정 (ex. 1 2 3 4 5 6 ...)
        calendar.appearance.titleFont = DSKitFontFamily.Pretendard.medium.font(size: 14)
        calendar.appearance.titlePlaceholderColor = DSKitAsset.Colors.gray300.color
        
        // 선택관련
        calendar.allowsMultipleSelection = false
        calendar.swipeToChooseGesture.isEnabled = false
        calendar.appearance.selectionColor = DSKitAsset.Colors.orange500.color
        calendar.appearance.titleSelectionColor = .white
        
        calendar.today = nil
    }
    
    private func setGesture() {
        
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(onPanGesture(_:)))
        
        view.addGestureRecognizer(recognizer)
    }
}

extension OneDayPickerViewController {
    
    /// viewDidAppear서브 뷰들의 레이아웃이 결정된 이후 시점(화면상에 나타난 시점)으로, frame, bounds에 근거있는 값들이 할당된 이후이다.
    public override func viewDidAppear(_ animated: Bool) {
        
        view.backgroundColor = .black.withAlphaComponent(0.0)
        let height = calendarInputView.bounds.height
        calendarInputView.isUserInteractionEnabled = false
        calendarInputView.transform = .init(translationX: 0, y: height)
        
        UIView.animate(withDuration: 0.35) { [calendarInputView, weak view] in
            calendarInputView.transform = .identity
            view?.backgroundColor = .black.withAlphaComponent(0.5)
        } completion: { [calendarInputView] _ in
            calendarInputView.isUserInteractionEnabled = true
        }
    }
    
    private func dismissView() {
        
        let height = calendarInputView.bounds.height
        calendarInputView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.2) { [calendarInputView, weak view] in
            calendarInputView.transform = .init(translationX: 0, y: height)
            view?.backgroundColor = .black.withAlphaComponent(0.0)
        } completion: { [weak self] _ in
            self?.dismiss(animated: false)
        }
    }
}

extension OneDayPickerViewController: FSCalendarDataSource {
    
    public func minimumDate(for calendar: FSCalendar) -> Date {
        Calendar.current.date(byAdding: .day, value: 0, to: Date())!
    }
    
    public func maximumDate(for calendar: FSCalendar) -> Date {
        Calendar.current.date(byAdding: .day, value: 30, to: Date())!
    }
}

extension OneDayPickerViewController: FSCalendarDelegate {

    public func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        delegate?.oneDayPicker(selectedDate: date)
        
        // 선택시 종료
        dismissView()
    }
    
    public func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        return date >= calendar.minimumDate && date <= calendar.maximumDate
    }
}

extension OneDayPickerViewController: FSCalendarDelegateAppearance {
    
    // 날짜 컬러설정
    public func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        if date >= calendar.minimumDate && date <= calendar.maximumDate {
            return DSKitAsset.Colors.gray700.color
        }
        return DSKitAsset.Colors.gray100.color
    }
}

extension OneDayPickerViewController {
    
    @objc
    func onPanGesture(_ gesture: UIPanGestureRecognizer) {
        
        let currentTouchPos = gesture.numberOfTouches > 0 ? gesture.location(ofTouch: 0, in: view) : .zero
        
        switch gesture.state {
        case .began:
            // 드래그 스페이스 내에서 드래그를 해야함
            gestureBeganPosition = currentTouchPos
            
        case .changed:
            
            lastGesturePosition = currentTouchPos
            
            let moveDistance = currentTouchPos.y - gestureBeganPosition.y
            
            if moveDistance >= 0 {
                // 제스처를 아래로 한 경우
                calendarInputView.transform = .init(translationX: 0, y: moveDistance)
            }
 
        case .ended, .cancelled:
            
            let moveDistance = lastGesturePosition.y-gestureBeganPosition.y
            
            if moveDistance >= 65 {
                // 특정 길이만큼 드래그한 경우, 화면닫기
                dismissView()
                
            } else {
                UIView.animate(withDuration: 0.35) { [calendarInputView] in
                    calendarInputView.transform = .identity
                }
            }
            
        default:
            return;
        }
    }
}
