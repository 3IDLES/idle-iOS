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

/// 달력뷰를 바텀시트로 표출하는 뷰 입니다.
public class OneDayPickerViewController: IdleButtomSheetVC {
    
    // View
    public let calendar = FSCalendar()
    
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
    
    public override func setAppearance() { }
    
    private func setLayout() {
        super.setLayout(contentView: calendar)
        // Calendar높이 설정
        NSLayoutConstraint.activate([
            calendar.heightAnchor.constraint(equalToConstant: 320),
        ])
    }
    
    private func setObservable() { }
    
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
