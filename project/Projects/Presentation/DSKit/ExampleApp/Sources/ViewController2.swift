//
//  ViewController2.swift
//  DSKit
//
//  Created by choijunios on 7/7/24.
//

import UIKit
import DSKit

class ViewController2: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.backgroundColor = .white
        
        view.layoutMargins = .init(
            top: 0,
            left: 20,
            bottom: 0,
            right: 20
        )
        
        let st1 = StateButtonTyp1(text: "여성", initial: .normal)
        let st2 = StateButtonTyp1(text: "남성", initial: .normal)
        
        
        [
            st1,
            st2
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }

        NSLayoutConstraint.activate([
            st1.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            st1.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            st1.heightAnchor.constraint(equalToConstant: 44),
            st1.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.5),
            
            st2.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.5),
            st2.heightAnchor.constraint(equalToConstant: 44),
            st2.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            st2.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
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
