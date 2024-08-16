//
//  ApplyManagementVC.swift
//  RootFeature
//
//  Created by choijunios on 7/25/24.
//

import UIKit

public class ApplyManagementVC: UIViewController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        setAppearacne()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearacne() {
        view.backgroundColor = .white
        
        let label = UILabel()
        label.text = "공고 관리 화면"
        
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
