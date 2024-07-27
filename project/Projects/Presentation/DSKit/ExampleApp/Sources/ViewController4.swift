//
//  ViewController4.swift
//  DSKitExampleApp
//
//  Created by choijunios on 7/27/24.
//

import UIKit
import DSKit

class ViewController4: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        let btn = CenterProfileButton(
            nameString: "세얼간이 요양보호소",
            locatonString: "용인시 어쩌고 저쩌고",
            isArrow: true
        )
        
//        btn.isArrow.accept(false)
        
        view.addSubview(btn)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            btn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
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
