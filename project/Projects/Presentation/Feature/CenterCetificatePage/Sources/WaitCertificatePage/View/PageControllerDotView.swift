//
//  PageControllerDotView.swift
//  CenterFeature
//
//  Created by choijunios on 9/29/24.
//

import UIKit
import PresentationCore
import Domain
import DSKit
import BaseFeature


import RxCocoa
import RxSwift

class PageControllerDotView: HStack {
    
    let accentColor = DSColor.orange500.color
    let normalColor = DSColor.gray100.color
    
    // Init
    let pageCnt: Int
    
    // View
    private var dotViews: [Int: UIView] = [:]
    
    init(pageCnt: Int) {
        self.pageCnt = pageCnt
        super.init([], spacing: 12)
        setLayout()
    }
    required init(coder: NSCoder) { fatalError() }
    
    func setLayout() {
        
        let viewList = (0..<pageCnt).map { index in
            let view = Spacer(width: 8, height: 8)
            view.backgroundColor = normalColor
            view.layer.cornerRadius = 4
            
            dotViews[index] = view
            
            return view
        }
        
        viewList.forEach {
            self.addArrangedSubview($0)
        }
    }
    
    func activateView(_ index: Int) {
        
        dotViews.forEach { (key, view) in

            view.backgroundColor = key == index ? accentColor : normalColor
         }
    }
}
