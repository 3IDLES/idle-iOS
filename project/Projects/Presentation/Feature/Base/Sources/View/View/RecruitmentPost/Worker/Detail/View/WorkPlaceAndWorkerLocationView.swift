//
//  WorkPlaceAndWorkerLocationView.swift
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

public class WorkPlaceAndWorkerLocationView: VStack {
    
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
        
    }
    
    private func setObservable() {
        
    }
    
    public func bind(locationRO: WorkPlaceAndWorkerLocationMapRO) {
        
        // 마커 설정
        let workPlacePos: NMGLatLng = .init(
            lat: locationRO.workPlaceLocation.latitude,
            lng: locationRO.workPlaceLocation.longitude
        )
        let workerPos: NMGLatLng = .init(
            lat: locationRO.workerLocation.latitude,
            lng: locationRO.workerLocation.longitude
        )
        
        let workPlaceMarker = NMFMarker(
            position: workPlacePos,
            iconImage: .init(image: DSIcon.workPlaceMarker.image)
        )
        let workerMarker = NMFMarker(
            position: workerPos,
            iconImage: .init(image: DSIcon.workerMarker.image)
        )
        [
            workPlaceMarker,
            workerMarker
        ].forEach { marker in
            marker.mapView = self.mapView.mapView
            marker.globalZIndex = 40001
        }
        // 근무지가 우선 표시도되도록
        workPlaceMarker.zIndex = 1
        workerMarker.zIndex = 0
        
        // 경로선
        let pathOverlay = NMFPath()
        pathOverlay.path = NMGLineString(points: [
            workPlacePos,
            workerPos
        ])
        pathOverlay.width = 3
        pathOverlay.outlineWidth = 0
        pathOverlay.progress = 0
        pathOverlay.color = DSColor.orange400.color
        
        // 카메라 이동
        let camerUpdate = NMFCameraUpdate(
            fit: .init(
                latLngs: [
                    workPlacePos,
                    workerPos,
                ]
            ),
            paddingInsets: .init(
                top: 42,
                left: 59,
                bottom: 44,
                right: 59
            )
        )
        self.mapView.mapView.moveCamera(camerUpdate)
        // 지도 Config
        let map = mapView.mapView
        map.mapType = .basic
        map.symbolScale = 2
        
        // - 제스처 끄기
        map.isScrollGestureEnabled = false
        map.isZoomGestureEnabled = false
        map.isTiltGestureEnabled = false
        map.isRotateGestureEnabled = false
        map.isStopGestureEnabled = false
        
        // 지도 뷰 Config
        mapView.showCompass = false
        mapView.showScaleBar = false
        mapView.showZoomControls = false
        mapView.showLocationButton = false
    }
}
