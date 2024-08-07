//
//  WorkLocationView.swift
//  BaseFeature
//
//  Created by choijunios on 8/7/24.
//

import UIKit
import PresentationCore
import RxCocoa
import RxSwift
import Entity
import DSKit
import NMapsMap

public class WorkLocationView: VStack {
    
    // Init
    
    // View
    let walkToLocationLabel: UILabel = {
        let label = UILabel()
        label.text = "거주지에서--"
        return label
    }()
    
    let timeCostByWalkLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
        label.textString = "걸어서 ~ 소요"
        label.textAlignment = .left
        return label
    }()
    
    let mapView: NMFNaverMapView = {
       
        let view = NMFNaverMapView(frame: .zero)
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init([], spacing: 16, alignment: .fill)
        setAppearance()
        setLayout()
    }
    
    public required init(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        
    }
    
    private func setLayout() {
        
        let walkingImage = DSKitAsset.Icons.walkingHuman.image.toView()
        let timeCostStack = HStack([walkingImage, timeCostByWalkLabel], spacing: 6, alignment: .center)
        
        let labelStack = VStack([walkToLocationLabel, timeCostStack], spacing: 4, alignment: .leading)
        
        [
            labelStack,
            mapView
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mapView.heightAnchor.constraint(equalToConstant: 224),
        ])
    }
    
    private func setLocationLabel(roadAddress: String) {
        let text = "거주지에서 \(roadAddress) 까지"
        var normalAttr = Typography.Body2.attributes
        normalAttr[.foregroundColor] = DSKitAsset.Colors.gray500.color
        
        let attrText = NSMutableAttributedString(string: text, attributes: normalAttr)
        
        let roadTextFont = Typography.Subtitle3.attributes[.font]!
        
        let range = NSRange(text.range(of: roadAddress)!, in: text)
        attrText.addAttribute(.font, value: roadTextFont, range: range)
        
        walkToLocationLabel.attributedText = attrText
    }
    
    private func configureMapAppearance() {
        
        mapView.mapView.touchDelegate = self
        
        let initialCoordinate = NMGLatLng(lat: 37.5666102, lng: 126.9783881)
        let cameraPosition = NMFCameraPosition(initialCoordinate, zoom: 1.0)
        
        mapView.mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))
        mapView.showZoomControls = false
    }
    
    private func setObservable() {
        
    }
    
    public func bind() {
        configureMapAppearance()
    }
}

extension WorkLocationView: NMFMapViewTouchDelegate {
    public func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        
        printIfDebug("\(latlng.lat), \(latlng.lng)")
    }
}
