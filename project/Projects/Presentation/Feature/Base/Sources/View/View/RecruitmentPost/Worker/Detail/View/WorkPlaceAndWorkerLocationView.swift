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

public struct WorkPlaceAndWorkerLocationMapRO {
    
    let workPlaceRoadAddress: String
    let homeToworkPlaceText: NSMutableAttributedString
    let estimatedArrivalTimeText: String
    
    let workPlaceLocation: LocationInformation
    let workerLocation: LocationInformation?
}

public class WorkPlaceAndWorkerLocationView: VStack {
    
    // Init
    
    // View
    let walkToLocationLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    let estimatedArrivalTimeTextLabel: IdleLabel = {
        let label = IdleLabel(typography: .Subtitle2)
        label.textString = ""
        label.textAlignment = .left
        return label
    }()
    
    public let mapViewBackGround: TappableUIView = {
        let view = TappableUIView()
        view.backgroundColor = DSColor.gray050.color
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    let mapView: NMFNaverMapView = {
        let view = NMFNaverMapView(frame: .zero)
        view.backgroundColor = DSColor.gray050.color
        view.isUserInteractionEnabled = false
        return view
    }()
    
    // Observable
    private let disposeBag = DisposeBag()
    
    public init() {
        super.init([], spacing: 16, alignment: .fill)
        setAppearance()
        setLayout()
        setObservable()
    }
    
    public required init(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        
    }
    
    private func setLayout() {
        
        let walkingImage = DSKitAsset.Icons.walkingHuman.image.toView()
        let timeCostStack = HStack([walkingImage, estimatedArrivalTimeTextLabel], spacing: 6, alignment: .center)
        
        let labelStack = VStack([walkToLocationLabel, timeCostStack], spacing: 4, alignment: .leading)
        
        mapViewBackGround.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: mapViewBackGround.topAnchor),
            mapView.leftAnchor.constraint(equalTo: mapViewBackGround.leftAnchor),
            mapView.rightAnchor.constraint(equalTo: mapViewBackGround.rightAnchor),
            mapView.bottomAnchor.constraint(equalTo: mapViewBackGround.bottomAnchor),
        ])
        
        [
            labelStack,
            mapViewBackGround
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            self.addArrangedSubview($0)
        }
        
        NSLayoutConstraint.activate([
            mapViewBackGround.heightAnchor.constraint(equalToConstant: 224),
        ])
    }
    
    private func setObservable() {
        
    }
    
    public func bind(locationRO: WorkPlaceAndWorkerLocationMapRO) {
        
        walkToLocationLabel.attributedText = locationRO.homeToworkPlaceText
        estimatedArrivalTimeTextLabel.textString = locationRO.estimatedArrivalTimeText
        
        if locationRO.workPlaceLocation != .notFound {
            
            mapView.bind(
                locationRO: locationRO,
                paddingInsets: .init(
                    top: 42,
                    left: 59,
                    bottom: 44,
                    right: 59
                )
            )
        } else {
            
            // 맵뷰 숨김처리
            mapViewBackGround.isHidden = true
        }
        
        // - 제스처 끄기
        mapView.mapView.isScrollGestureEnabled = false
        mapView.mapView.isZoomGestureEnabled = false
        mapView.mapView.isTiltGestureEnabled = false
        mapView.mapView.isRotateGestureEnabled = false
        mapView.mapView.isStopGestureEnabled = false
        
        // 지도 뷰 Config
        mapView.showCompass = false
        mapView.showScaleBar = false
        mapView.showZoomControls = false
        mapView.showLocationButton = false
    }
}


extension NMFNaverMapView {
    
    func bind(
        locationRO: WorkPlaceAndWorkerLocationMapRO,
        paddingInsets: UIEdgeInsets
    ) {
        // 마커 설정
        let workPlacePos: NMGLatLng = .init(
            lat: locationRO.workPlaceLocation.latitude,
            lng: locationRO.workPlaceLocation.longitude
        )
        
        var posArr = [workPlacePos]
        
        var workerPos: NMGLatLng?
        
        if let workerLocation = locationRO.workerLocation {
            workerPos = .init(
                lat: workerLocation.latitude,
                lng: workerLocation.longitude
            )
            posArr.append(workerPos!)
        }
        
        let workPlaceMarker = NMFMarker(
            position: workPlacePos,
            iconImage: .init(image: DSIcon.workPlaceMarker.image)
        )
        workPlaceMarker.width = 41
        workPlaceMarker.height = 56
        
        var markerArr = [workPlaceMarker]
        
        var workerMarker: NMFMarker?
        
        if let workerPos {
            workerMarker = .init(
                position: workerPos,
                iconImage: .init(image: DSIcon.workerMarker.image)
            )
            workerMarker?.width = 33
            workerMarker?.height = 44
            
            markerArr.append(workerMarker!)
        }
        
        
        markerArr.forEach { marker in
            marker.mapView = self.mapView
            marker.globalZIndex = 40001
            marker.anchor = .init(x: 0.5, y: 1)
        }
        
        // 경로선
        if posArr.count == 2 {
            let pathOverlay = NMFPath()
            pathOverlay.path = .init(points: posArr)
            pathOverlay.width = 3
            pathOverlay.outlineWidth = 0
            pathOverlay.color = DSColor.orange400.color
            pathOverlay.mapView = self.mapView
            pathOverlay.globalZIndex = 40001
            pathOverlay.zIndex = 0
        }
        // 근무지가 우선 표시도되도록
        workPlaceMarker.zIndex = 2
        workerMarker?.zIndex = 1
        
        
        // 카메라 이동
        let camerUpdate = NMFCameraUpdate(
            fit: .init(
                latLngs: posArr
            ),
            paddingInsets: paddingInsets
        )
        self.mapView.moveCamera(camerUpdate)
        
        if mapView.zoomLevel > 18 {
            mapView.zoomLevel = 18
        }
        
        // 지도 Config
        let map = self.mapView
        map.mapType = .basic
        map.symbolScale = 2
    }
}
