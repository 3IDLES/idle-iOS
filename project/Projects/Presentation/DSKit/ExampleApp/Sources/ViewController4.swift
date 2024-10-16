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
        
        let label = TagLabel(text: "Hello", typography: .Body3, textColor: .black, backgroundColor: .cyan)
        
        
        
        let textField = MultiLineTextField(typography: .Body3, placeholderText: "Hello")
        textField.setKeyboardAvoidance(movingView: view)
        textField.isScrollEnabled = false
        
//        btn.isArrow.accept(false)
        [
            label,
        ].forEach {
            
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        
        NSLayoutConstraint.activate([
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
//            btn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
//            
//            textField.topAnchor.constraint(equalTo: btn.bottomAnchor, constant: 100),
//            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
//            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
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
