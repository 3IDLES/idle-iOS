//
//  DependencyInjector.swift
//  Idle-iOS
//
//  Created by 최준영 on 6/22/24.
//

import Swinject

/// DI 대상 등록Swinject-Dynamic
public protocol DependencyAssemblable {
    func assemble(_ assemblyList: [Assembly])
    func register<T>(_ serviceType: T.Type, _ object: T)
}

/// DI 등록한 서비스 사용
public protocol DependencyResolvable {
    func resolve<T>(_ serviceType: T.Type) -> T
}

public typealias Injector = DependencyAssemblable & DependencyResolvable

public final class DependencyInjector: Injector {
    private let container: Container
    
    public init(container: Container = Container()) {
        self.container = container
    }
    
    public func assemble(_ assemblyList: [Assembly]) {
        assemblyList.forEach {
            $0.assemble(container: container)
        }
    }
    
    public func register<T>(_ serviceType: T.Type, _ object: T) {
        container.register(serviceType) { _ in object }
    }
    
    public func resolve<T>(_ serviceType: T.Type) -> T {
        container.resolve(serviceType)!
    }
}
