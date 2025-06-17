//
//  RxASAuthorizationControllerDelegateProxy.swift
//  Routory
//
//  Created by 서동환 on 6/18/25.
//

import Foundation
import AuthenticationServices
import RxCocoa
import RxSwift

extension ASAuthorizationController: HasDelegate {}

final class RxASAuthorizationControllerDelegateProxy: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate>, DelegateProxyType, ASAuthorizationControllerDelegate {
    
    weak public private(set) var authController: ASAuthorizationController?
    
    public init(authController: ParentObject) {
        self.authController = authController
        super.init(parentObject: authController, delegateProxy: RxASAuthorizationControllerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        register { RxASAuthorizationControllerDelegateProxy(authController: $0) }
    }
}

public extension Reactive where Base: ASAuthorizationController {
    var delegate: DelegateProxy<ASAuthorizationController, ASAuthorizationControllerDelegate> {
        RxASAuthorizationControllerDelegateProxy.proxy(for: base)
    }
    
    func setDelegate(_ delegate: ASAuthorizationControllerDelegate) -> Disposable {
        RxASAuthorizationControllerDelegateProxy.installForwardDelegate(delegate,
                                                                        retainDelegate: false,
                                                                        onProxyForObject: self.base)
    }
    
    var didCompleteWithAuthorization: Observable<ASAuthorizationCredential> {
        return delegate.methodInvoked(#selector(ASAuthorizationControllerDelegate.authorizationController(controller:didCompleteWithAuthorization:)))
            .map { parameters in
                return (parameters[1] as! ASAuthorization).credential
            }
    }
}
