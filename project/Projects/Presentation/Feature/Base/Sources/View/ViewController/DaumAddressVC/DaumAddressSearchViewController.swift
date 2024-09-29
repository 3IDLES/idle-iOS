//
//  DaumAddressSearchViewController.swift
//  BaseFeature
//
//  Created by choijunios on 7/15/24.
//

import UIKit
import DSKit
import Domain
import WebKit
import PresentationCore
import Core


import RxSwift
import RxCocoa

public enum AddressDataKey: String, CaseIterable {
    case address="address"
    case jibunAddress="jibunAddress"
    case roadAddress="roadAddress"
    case autoRoadAddress="autoRoadAddress"
    case autoJibunAddress="autoJibunAddress"
}

public protocol DaumAddressSearchDelegate: AnyObject {
    func addressSearch(addressData: [AddressDataKey: String])
}

class LeakAvoider: NSObject, WKScriptMessageHandler {
    weak var delegate: WKScriptMessageHandler?
    init(delegate: WKScriptMessageHandler) {
        self.delegate = delegate
        super.init()
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        self.delegate?.userContentController(userContentController, didReceive: message)
    }
}

public class DaumAddressSearchViewController: UIViewController & WKUIDelegate & WKNavigationDelegate & WKScriptMessageHandler {
    
    public weak var delegate: DaumAddressSearchDelegate?
    
    // View
    private let navigationBar: NavigationBarType1 = {
       
        let bar = NavigationBarType1(
            navigationTitle: "주소찾기"
        )
        return bar
    }()
    
    private let webRequest: URLRequest = {
        let gitURL = URL(string: "https://j0onyeong.github.io/DaumAddressApiPage")!
        let request = URLRequest(url: gitURL)
        return request
    }()
    
    private var searchView: WKWebView!
    
    private let disposeBag = DisposeBag()

    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) { fatalError() }
    
    public override func viewDidLoad() {
        
        setAppearance()
        setWebView()
        setAutoLayout()
        setObservable()
    }
    
    private func setWebView() {
        let webConfiguration = WKWebViewConfiguration()
        let contentController = WKUserContentController()
        contentController.add(LeakAvoider(delegate: self), name: "getAddress_IOS")
        webConfiguration.userContentController = contentController
        
        self.searchView = WKWebView(frame: .zero, configuration: webConfiguration)
        searchView.uiDelegate = self
        searchView.navigationDelegate = self
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        searchView.load(webRequest)
    }
    
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
            navigationBar.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 21),
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
            .subscribe { [weak self] _ in
                
                guard let self else { return }
                
                navigationController?.popViewController(animated: true)
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
        delegate?.addressSearch(addressData: addressData)
        
        navigationController?.popViewController(animated: true)
    }
}


