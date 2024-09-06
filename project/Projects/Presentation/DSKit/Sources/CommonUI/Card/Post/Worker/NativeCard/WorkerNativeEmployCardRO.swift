//
//  WorkerNativeEmployCardRO.swift
//  DSKit
//
//  Created by choijunios on 7/19/24.
//

import UIKit
import RxSwift
import RxCocoa
import Entity

// MARK: Render object
public class WorkerNativeEmployCardRO {
    
    let showBiginnerTag: Bool
    let titleText: String
    let timeDurationForWalkingText: String
    let targetInfoText: String
    let workDaysText: String
    let workTimeText: String
    let payText: String
    let isFavorite: Bool
    
    init(
        showBiginnerTag: Bool,
        titleText: String,
        timeDurationForWalkingText: String,
        targetInfoText: String,
        workDaysText: String,
        workTimeText: String,
        payText: String,
        isFavorite: Bool
    ) {
        self.showBiginnerTag = showBiginnerTag
        self.titleText = titleText
        self.timeDurationForWalkingText = timeDurationForWalkingText
        self.targetInfoText = targetInfoText
        self.workDaysText = workDaysText
        self.workTimeText = workTimeText
        self.payText = payText
        self.isFavorite = isFavorite
    }
    
    public static func create(vo: WorkerNativeEmployCardVO) -> WorkerNativeEmployCardRO {

//        var dayLeftTagText: String? = nil
//        var showDayLeftTag: Bool = false
//
//        if (0...14).contains(vo.dayLeft) {
//            showDayLeftTag = true
//            dayLeftTagText = vo.dayLeft == 0 ? "D-Day" : "D-\(vo.dayLeft)"
//        }
       
        let targetInfoText = "\(vo.careGrade.textForCellBtn)등급 \(vo.targetAge)세 \(vo.targetGender.twoLetterKoreanWord)"
        
        let workDaysText = vo.days.sorted(by: { d1, d2 in
            d1.rawValue < d2.rawValue
        }).map({ $0.korOneLetterText }).joined(separator: ",")
        
        let workTimeText = "\(vo.startTime) - \(vo.endTime)"
        
        var formedPayAmountText = ""
        for (index, char) in vo.paymentAmount.reversed().enumerated() {
            if (index % 3) == 0, index != 0 {
                formedPayAmountText = "," + formedPayAmountText
            }
            formedPayAmountText = String(char) + formedPayAmountText
        }
        
        let payText = "\(vo.paymentType.korLetterText) \(formedPayAmountText) 원"
        
        var splittedAddress = vo.title.split(separator: " ")
        
        if splittedAddress.count >= 3 {
            splittedAddress = Array(splittedAddress[0..<3])
        }
        let addressTitle = splittedAddress.joined(separator: " ")
        
        // distance는 미터단위입니다.
        let durationText = Self.timeForDistance(meter: vo.distanceFromWorkPlace)
        
        return .init(
            showBiginnerTag: vo.isBeginnerPossible,
            titleText: addressTitle,
            timeDurationForWalkingText: durationText,
            targetInfoText: targetInfoText,
            workDaysText: workDaysText,
            workTimeText: workTimeText,
            payText: payText,
            isFavorite: vo.isFavorite
        )
    }
    
    public static let `mock`: WorkerNativeEmployCardRO = .init(
        showBiginnerTag: true,
        titleText: "사울시 강남동",
        timeDurationForWalkingText: "도보 15분 ~ 20분",
        targetInfoText: "1등급 54세 여성",
        workDaysText: "",
        workTimeText: "월, 화, 수",
        payText: "시급 5000원",
        isFavorite: true
    )
    
    static func timeForDistance(meter: Int) -> String {
        switch meter {
        case 0..<200:
            return "도보 5분 이내"
        case 200..<400:
            return "도보 5 ~ 10분"
        case 400..<700:
            return "도보 10 ~ 15분"
        case 700..<1000:
            return "도보 15 ~ 20분"
        case 1000..<1250:
            return "도보 20 ~ 25분"
        case 1250..<1500:
            return "도보 25 ~ 30분"
        case 1500..<1750:
            return "도보 30 ~ 35분"
        case 1750..<2000:
            return "도보 35 ~ 40분"
        default:
            return "도보 40분 ~"
        }
    }
}
