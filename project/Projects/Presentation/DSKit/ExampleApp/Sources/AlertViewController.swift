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
        let alertVC = IdleSmallAlertController(
            titleText: "정말 탈퇴하시겠어요?"
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
