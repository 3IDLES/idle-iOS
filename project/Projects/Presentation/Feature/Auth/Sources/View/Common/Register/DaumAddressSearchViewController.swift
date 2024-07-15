//
//  DaumAddressSearchViewController.swift
//  AuthFeature
//
//  Created by choijunios on 7/15/24.
//

import UIKit
import RxSwift
import RxCocoa
import DSKit
import Entity
import PresentationCore
import WebKit

public enum AddressDataKey: String, CaseIterable {
    case address="address"
    case jibunAddress="jibunAddress"
    case roadAddress="roadAddress"
}

public protocol DaumAddressSearchDelegate {
    func addressSearch(addressData: [AddressDataKey: String])
}

public typealias Conformance = UIViewController & WKUIDelegate & WKNavigationDelegate & WKScriptMessageHandler

public class DaumAddressSearchViewController: Conformance {
    
    public var deleage: DaumAddressSearchDelegate?
    
    // View
    private let navigationBar: NavigationBarType1 = {
       
        let bar = NavigationBarType1(
            navigationTitle: "주소찾기"
        )
        return bar
    }()
    
    private lazy var searchView: WKWebView = {
        let gitURL = URL(string: "https://j0onyeong.github.io/DaumAddressApiPage")!
        let request = URLRequest(url: gitURL)
        
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(self as WKScriptMessageHandler, name: "getAddress_IOS")
        webConfiguration.userContentController = contentController
        
        let webView = WKWebView(frame: view.bounds, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.load(request)
        
        return webView
    }()
    
    private let disposeBag = DisposeBag()

    public init() {
        super.init(nibName: nil, bundle: nil)
        setAppearance()
        setAutoLayout()
        setObservable()
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    private func setAppearance() {
        view.layoutMargins = .init(top: 0, left: 0, bottom: 0, right: 0)
        view.backgroundColor = .white
    }
    
    private func setAutoLayout() {

        [
            navigationBar,
            searchView,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            navigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            
            searchView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 32),
            searchView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            searchView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            searchView.bottomAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setObservable() {
        
        navigationBar
            .eventPublisher
            .subscribe { [unowned self] _ in
                self.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}

public extension DaumAddressSearchViewController {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
        printIfDebug("✅ Message received: \(message.name)")
        
        guard let dataDict = message.body as? [String: Any] else { fatalError() }
        
        var addressData: [AddressDataKey: String] = [:]
        
        AddressDataKey.allCases.forEach { key in
            if let address = dataDict[key.rawValue] as? String {
                addressData[key] = address
            }
        }
        deleage?.addressSearch(addressData: addressData)
        
        navigationController?.popViewController(animated: true)
    }
}


