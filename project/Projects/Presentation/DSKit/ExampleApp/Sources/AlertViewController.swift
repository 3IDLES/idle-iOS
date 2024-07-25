//
//  AlertViewController.swift
//  DSKitExampleApp
//
//  Created by choijunios on 7/25/24.
//

import UIKit
import DSKit

class AlertViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let alertVC = IdleBigAlertController(
            titleText: "정말 탈퇴하시겠어요?",
            descriptionText: "탈퇴 버튼 선택 시 모든 정보가 삭제되며, 되돌릴 수 없습니다.",
            button1Info: .init(
                text: "취소하기",
                backgroundColor: .white,
                accentColor: DSKitAsset.Colors.gray100.color
            ),
            button2Info: .init(
                text: "탈퇴하기",
                backgroundColor: DSKitAsset.Colors.orange500.color,
                accentColor: DSKitAsset.Colors.orange700.color
            )
        )
        
        alertVC.modalPresentationStyle = .fullScreen
        self.present(alertVC, animated: false)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
