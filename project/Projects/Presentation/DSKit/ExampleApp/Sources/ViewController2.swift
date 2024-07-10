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
        
        let box = InfoBox(
            titleText: "세얼간이 요양 보호소",
            items: [
                (key: "주소1", value: "강남구 개포동"),
                (key: "주소2", value: "강남구 개포동 테헤란로"),
                (key: "주소3", value: "서울시 영등포구 서울시 영등포구 서울시 영등포구 서울시 영등포구 서울시 영등포구"),
            ]
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            box.titleText.onNext("Hello world")
            
            box.items.onNext([
                (key: "주소1", value: "강남구 대치동"),
                (key: "주소2", value: "강남구 역삼동"),
                (key: "주소3", value: "서울시 영등포구"),
            ])
        }
        
        
        let textField = IdleOneLineInputField(
            placeHolderText: "placeHolderText"
        )
        
        var fontSize: CGFloat = 10
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            
            fontSize+=2;
            
            DispatchQueue.main.async {
                
                textField.textField.font = .systemFont(ofSize: fontSize)
            }
        }
        
        
        let textFieldType2 = IFType2(
            titleLabelText: "타이틀 라벨",
            placeHolderText: "아이디 입력"
        )
        
        [
            box,
            textField,
            textFieldType2,
        ].forEach {
            
            view.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            box.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            box.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            box.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: box.bottomAnchor, constant: 30),
            textField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            textFieldType2.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 30),
            textFieldType2.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            textFieldType2.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
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
