//
//  ViewController3.swift
//  DSKitExampleApp
//
//  Created by choijunios on 7/17/24.
//

import UIKit
import DSKit
import RxSwift

class ViewController3: UIViewController {
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        
        view.backgroundColor = .white
        
        let tableView = UITableView()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(WorkerEmployCard.self, forCellReuseIdentifier: String(describing: WorkerEmployCard.self))
        [
            tableView
        ]
            .forEach {
                $0.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview($0)
            }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension ViewController3: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: WorkerEmployCard.self), for: indexPath) as? WorkerEmployCard else {
            fatalError("Unable to dequeue WorkerEmployCard")
        }
        cell.bind()
        return cell
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false // 셀 하이라이트 비활성화
    }
}
