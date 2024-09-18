//
//  WorkPlaceAndWorkerLocationFullVC.swift
//  BaseFeature
//
//  Created by choijunios on 8/16/24.
//

import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit
import NMapsMap

public class WorkPlaceAndWorkerLocationFullVC: BaseViewController {
    
    // Init
    
    // View
    let navigationBar: IdleNavigationBar = {
        let bar = IdleNavigationBar(
            titleText: "",
            innerViews: []
        )
        return bar
    }()
    
    let mapView: NMFNaverMapView = {
        let view = NMFNaverMapView(frame: .zero)
        view.backgroundColor = DSColor.gray050.color
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        setAppearance()
        setLayout()
        setObservable()
    }
    
    private func setAppearance() {
        view.backgroundColor = DSColor.gray0.color
    }
    
    private func setLayout() {
        [
            navigationBar,
            mapView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            navigationBar.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            mapView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            mapView.leftAnchor.constraint(equalTo: view.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: view.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
    
    private func setObservable() {
        navigationBar.backButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    public func bind(locationRO: WorkPlaceAndWorkerLocationMapRO) {
        
        navigationBar.titleLabel.textString = locationRO.workPlaceRoadAddress
        
        mapView.bind(
            locationRO: locationRO,
            paddingInsets: .init(
                top: 0,
                left: 71,
                bottom: 0,
                right: 71
            )
        )
        
        // 지도 뷰 Config
        mapView.showLocationButton = false
        mapView.showZoomControls = true
    }
}

