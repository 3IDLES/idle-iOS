//
//  SelectCSTypeVC.swift
//  BaseFeature
//
//  Created by choijunios on 8/8/24.
//

import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit

public class SelectCSTypeVC: IdleBottomSheetVC {
    
    // Init
    
    // View
    let phoneCSButton: PhoneCSButton = .init()
    
    public override init() {
        super.init()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
    }
    
    private func setLayout() {
        
        let csLabel = IdleLabel(typography: .Heading3)
        csLabel.textString = "문의하기"
        csLabel.textAlignment = .center
        
        let viewList = [
            csLabel,
            phoneCSButton
        ]
        
        let contentView = VStack(viewList, spacing: 20, alignment: .fill)
        
        super.setLayout(contentView: contentView)
    }
    
    private func setObservable() {
        
    }
    
}

@available(iOS 17.0, *)
#Preview("Preview", traits: .defaultLayout) {
    
    SelectCSTypeVC()
}
